import { Dynamic } from "../model/Dynamic";
import { DyUpper } from "../model/DyUpper";
import { ErrorMsg } from "../model/ErrorMsg";
import { httpRequestGet } from "../utils/HttpUtil";

export class DynamicViewModel{

  static async getUpList() : Promise<DyUpper[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/polymer/web-dynamic/v1/portal`;
    return httpRequestGet(url).then((result) => {
      if (result?.["code"] == 0) {
        let data = result?.["data"]?.["up_list"] as DyUpper[];
        return data!;
      }
      return new ErrorMsg(result?.["message"]);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getDynamics(hostMid: string, type: string = "all") : Promise<Dynamic[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all?type=${type}&host_mid=${hostMid}`;
    return httpRequestGet(url).then((result) => {
      if (result?.["code"] == 0) {
        let data = result?.["data"]?.["items"] as Dynamic[];
        return data!;
      }
      return new ErrorMsg(result?.["message"]);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }
}