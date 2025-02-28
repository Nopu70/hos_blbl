import { ErrorMsg } from "../model/ErrorMsg";
import { DMInfo, LiveUrl } from "../model/LiveUrl";
import { httpRequestGet } from "../utils/HttpUtil";

export class RoomViewModel {

  static async getUrl(roomId: number, qn?: number) : Promise<string | ErrorMsg> {
    let url = `https://api.live.bilibili.com/room/v1/Room/playUrl?cid=${roomId}&qn=${qn ?? ""}&platform=h5`;
    return httpRequestGet(url).then((result) => {
      let data = result["data"]["durl"][0]["url"] as string;
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getUrlv2(roomId: number, qn?: number) : Promise<string | ErrorMsg> {
    let url = `https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo?device=phone&platform=html5&scale=3&build=10000&protocol=1&format=2&codec=1&room_id=${roomId}`;
    return httpRequestGet(url).then((result) => {
      let codec = result["data"]["playurl_info"]["playurl"]["stream"][0]["format"][0]["codec"][0] as object;
      let url_info = codec["url_info"][0] as object;
      let data = url_info["host"] as string + codec["base_url"] + url_info["extra"];
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getDMInfo(roomId: number) : Promise<DMInfo | ErrorMsg> {
    let url = `https://api.live.bilibili.com/xlive/web-room/v1/index/getDanmuInfo?id=${roomId}`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as DMInfo;
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }
}