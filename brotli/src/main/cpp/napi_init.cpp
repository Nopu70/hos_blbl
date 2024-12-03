#include "napi/native_api.h"
#include "decode.h"
#include <cstdint>
#include <cstdlib>
#include <stdio.h>
#include <hilog/log.h>
#include <decode.h>
#include <encode.h>
#include <arpa/inet.h>

#define LOG_TAG "[Room][UNCOMPRESS]"

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

static napi_value parse_bl_dm(napi_env env, napi_callback_info info)
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
    uint8_t * decode_buf = (uint8_t *)malloc(decode_size);
    BrotliDecoderResult decResult = BrotliDecoderDecompress(encode_size, (const uint8_t *)encode_buf, &decode_size, decode_buf);
    if (decResult != BROTLI_DECODER_RESULT_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "解码数据失败 code:%{public}d", decResult);
        free(decode_buf);
        return nullptr;
    }
    
    napi_value dm_array;
    napi_create_array(env, &dm_array);
    int buf_index = 0;
    uint32_t dm_index = 0;
    Header *header;
    while (buf_index < encode_size) {
        header = (Header *)(decode_buf + buf_index);
        int p_size = ntohl(header->packet_size);
        if (p_size == 0) {
            OH_LOG_ERROR(LOG_APP, "数据包尺寸为0 index: %{public}d-%{public}d  buffer_size: %{public}zu", buf_index, dm_index, encode_size);
            break;
        }
        int h_size = ntohs(header->heard_size);
        napi_value dm;
        napi_create_string_utf8(env, (const char *)(decode_buf + buf_index + h_size), p_size - h_size, &dm);
        napi_set_element(env, dm_array, dm_index, dm);
        buf_index += p_size;
        dm_index++;
    }
    free(decode_buf);
    
    return dm_array;
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
