import { ErrorMsg } from "../model/ErrorMsg";
import { LiveArea, SecondAreaData } from "../model/Live";
import { httpRequestGet } from "../utils/HttpUtil";

export class LiveAreaViewModel {

  static async getParentArea(parentId: number): Promise<LiveArea[] | ErrorMsg> {
    let url = `https://api.live.bilibili.com/room/v1/area/getList?parent_id=${parentId}&platform=android`;
    return httpRequestGet(url).then((result) => {
      if (result["code"] === 0) {
        return result["data"] as LiveArea[];
      }
      return new ErrorMsg(result["message"]);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getSecondArea(parentId: number, areaId: number, type: string, page: number): Promise<SecondAreaData | ErrorMsg> {
    let url = `https://api.live.bilibili.com/xlive/web-interface/v1/second/getList?platform=android&parent_area_id=${parentId}&area_id=${areaId}&sort_type=${type}&page=${page}`;
    return httpRequestGet(url).then((result) => {
      if (result["code"] === 0) {
        return result["data"] as SecondAreaData;
      }
      return new ErrorMsg(result["message"]);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }
}