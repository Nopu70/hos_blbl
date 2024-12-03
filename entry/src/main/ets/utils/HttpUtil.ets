import http from "@ohos.net.http";
import { JSON } from "@kit.ArkTS";
import { image } from "@kit.ImageKit";


export function httpRequestGet(url: string): Promise<object> {
  let httpRequest = http.createHttp();
  return httpRequest.request(url, {
    method: http.RequestMethod.GET,
    header: {
      'Content-Type': 'application/json',
      'Cookie': AppStorage.get<string>("cookies"),
      'Referer': 'https://m.bilibili.com/',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36 Edg/130.0.0.0'
    }
  }).then((resp) => {
    if (resp.responseCode === http.ResponseCode.OK) {
      console.log(`net_request__${url}__` + resp.result);
      //Response可能会包含错误信息，这个暂时不知道错误信息的返回码是什么
      let r = JSON.parse(resp.result.toString());
      if (r) {
        return r;
      }
    }
    throw new Error("请求数据错误");
  });
}

export function httpRequestPost(url: string, params: string): Promise<object> {
  let httpRequest = http.createHttp();
  return httpRequest.request(url, {
    method: http.RequestMethod.POST,
    header: {
      'Content-Type': 'application/json',
      'Cookie': AppStorage.get<string>("cookies"),
      'Referer': 'https://m.bilibili.com/',
      'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36 Edg/130.0.0.0'
    }
  }).then((resp) => {
    if (resp.responseCode === http.ResponseCode.OK) {
      console.log(`net_request__${url}__` + resp.result);
      //Response可能会包含错误信息，这个暂时不知道错误信息的返回码是什么
      let r = JSON.parse(resp.result.toString());
      if (r) {
        return r;
      }
    }
    throw new Error("请求数据错误");
  });
}

export async function httpRequestPic(url: string, size: image.Size): Promise<PixelMap | string> {
  // let httpRequest = http.createHttp();
  // return httpRequest.request(url, {
  //   method: http.RequestMethod.GET,
  //   header: {
  //     'Content-Type': 'application/json',
  //     'Cookie': AppStorage.get<string>("cookies"),
  //     'Referer': 'https://m.bilibili.com/',
  //     'User-Agent': 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36 Edg/130.0.0.0'
  //   }
  // }).then((resp) => {
  //   if (resp.responseCode === http.ResponseCode.OK) {
  //     if (resp.result instanceof ArrayBuffer) {
  //       return image.createPixelMap(resp.result, {
  //         size: size,
  //         alphaType: image.AlphaType.UNKNOWN,
  //         editable: false,
  //         pixelFormat: image.PixelMapFormat.RGBA_8888,
  //         scaleMode: image.ScaleMode.CENTER_CROP
  //       })
  //     }
  //   }
  //   throw new Error("图片加载错误");
  // }).catch((error: BusinessError) => {
  //   console.error("net_request__" + error.message);
  //   return url;
  // })


  //createPixelMap 错误
  //https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-image-19-V5
  return url;
}