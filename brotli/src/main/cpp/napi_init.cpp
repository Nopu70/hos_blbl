#include "napi/native_api.h"
#include "decode.h"
#include <cstdint>
#include <cstdlib>
#include <stdio.h>
#include <hilog/log.h>
#include <decode.h>
#include <arpa/inet.h>
#include <vector>
#include <string>

#undef LOG_TAG
#define LOG_TAG "__BROTLI__"

static napi_value Uncompress(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    
    napi_value src_buf = args[0];
    
    bool result;
    napi_is_arraybuffer(env, src_buf, &result);
    if (!result) {
        OH_LOG_ERROR(LOG_APP, "不是ArrayBuffer");
        return nullptr;
    }
    
    void * encode_buf = nullptr;
    size_t encode_size = 0;
    napi_status status = napi_get_arraybuffer_info(env, src_buf, &encode_buf, &encode_size);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "获取buff失败");
        return nullptr;
    }
    
    size_t decode_size = 1024 * 128;
    void * decode_buf = (void *)malloc(decode_size);
    BrotliDecoderResult decResult = BrotliDecoderDecompress(encode_size, (const uint8_t *)encode_buf, &decode_size, (uint8_t *)decode_buf);
    if (decResult != BROTLI_DECODER_RESULT_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "解码数据失败 code:%{public}d", decResult);
        return nullptr;
    }
    
    napi_value result_string;
    status = napi_create_string_utf8(env, (const char *)decode_buf, decode_size, &result_string);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "转码字符串失败: error: %{public}d", status);
        return nullptr;
    }
    
    OH_LOG_ERROR(LOG_APP, "解码后的数据: size:%{public}zu %{public}s", decode_size, ((char*)decode_buf)+16);
    free(decode_buf);
    return result_string;
}

struct Header{
    uint32_t packet_size;
    uint16_t heard_size;
};

napi_value rejectMsg(napi_env env, const char* msg)
{
    napi_value error;
    napi_value errorMessage;
    napi_create_string_utf8(env, msg, NAPI_AUTO_LENGTH, &errorMessage);
    napi_create_error(env, NULL, errorMessage, &error);
    return error;
}

struct CallbackData {
    napi_async_work asyncWork = nullptr;
    napi_deferred deferred = nullptr;
    void* buffer;
    size_t buffer_size;
    std::vector<std::string> resultData;
    std::string error;
};

void executeCallback(napi_env env, void* data)
{
    CallbackData* cbData = static_cast<CallbackData*>(data);
    
    size_t decode_size = 1024 * 128;
    uint8_t decode_buf[decode_size];
    BrotliDecoderResult decResult = BrotliDecoderDecompress(cbData->buffer_size, (const uint8_t *)cbData->buffer, &decode_size, decode_buf);
    if (decResult != BROTLI_DECODER_RESULT_SUCCESS) {
        cbData->error = "解码数据失败: ";
        cbData->error += decResult;
        return;
    }
    
    uint32_t buf_index = 0;
    uint32_t dm_index = 0;
    Header *header;
    while (buf_index < decode_size) {
        header = (Header *)(decode_buf + buf_index);
        int p_size = ntohl(header->packet_size);
        int h_size = ntohs(header->heard_size);
        
        cbData->resultData.emplace_back((char*)decode_buf + buf_index + h_size, p_size - h_size);
        buf_index += p_size;
        dm_index++;
    }
}

void completeCallback(napi_env env, napi_status status, void* data)
{
    CallbackData* cbData = static_cast<CallbackData*>(data);
    if (status == napi_ok && cbData->error.empty()) {
        napi_value dm_array;
        napi_create_array(env, &dm_array);
        for (int i = 0; i < cbData->resultData.size(); i++) {
            auto& dm = cbData->resultData[i];
            napi_value dmStr;
            napi_create_string_utf8(env, dm.c_str(), dm.length(), &dmStr);
            napi_set_element(env, dm_array, i, dmStr);
        }
        napi_resolve_deferred(env, cbData->deferred, dm_array);
    } else {
        napi_reject_deferred(env, cbData->deferred, rejectMsg(env, cbData->error.c_str()));
    }
    napi_delete_async_work(env, cbData->asyncWork);
    delete cbData;
}

static napi_value parse_bl_dm(napi_env env, napi_callback_info info)
{
    napi_value promise;
    napi_deferred deferred;
    napi_status status = napi_create_promise(env, &deferred, &promise);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Create promise failed");
        return nullptr;
    }
    
    size_t argc = 1;
    napi_value src_buf = nullptr;
    napi_get_cb_info(env, info, &argc, &src_buf , nullptr, nullptr);
    
    bool result;
    napi_is_arraybuffer(env, src_buf, &result);
    if (!result) {
        napi_reject_deferred(env, deferred, rejectMsg(env, "不是ArrayBuffer"));
        return promise;
    }
    
    CallbackData* data = new CallbackData;
    data->deferred = deferred;
    
    status = napi_get_arraybuffer_info(env, src_buf, &data->buffer, &data->buffer_size);
    if (status != napi_ok) {
        napi_reject_deferred(env, deferred, rejectMsg(env, "获取buff失败"));
        delete data;
        return promise;
    }
    
    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "parse_dm", NAPI_AUTO_LENGTH, &resourceName);
    // 创建异步任务
    napi_create_async_work(env, nullptr, resourceName, executeCallback, completeCallback, data, &data->asyncWork);
    // 将异步任务加入队列
    napi_queue_async_work(env, data->asyncWork);
    
    return promise;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "uncompress", nullptr, Uncompress, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "parseBiliDm", nullptr, parse_bl_dm, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "brotli",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterBrotliModule(void)
{
    napi_module_register(&demoModule); 
}
