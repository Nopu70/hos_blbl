import { ErrorMsg } from "../model/ErrorMsg";
import { DMInfo, LiveUrl } from "../model/LiveUrl";
import { httpRequestGet } from "../utils/HttpUtil";

export class RoomViewModel {

  static async getUrl(roomId: number, qn?: number) : Promise<LiveUrl | ErrorMsg> {
    let url = `https://api.live.bilibili.com/room/v1/Room/playUrl?cid=${roomId}&qn=${qn ?? ""}&platform=h5`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as LiveUrl;
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