import { ErrorMsg } from "../model/ErrorMsg";
import { AreaEntrance, LiveGridItem, Module } from "../model/Live";
import { httpRequestGet } from "../utils/HttpUtil";
import { taskpool } from "@kit.ArkTS";

@Concurrent
function parseData(obj: object): [AreaEntrance[], LiveGridItem[]] {
  let areas = obj["data"]["area_entrance_v2"]["list"] as AreaEntrance[];
  let modules = obj["data"]["room_list"] as Module[];
  let items: LiveGridItem[] = [];
  modules.forEach((module, indxe) => {
    items.push({ value: module.module_info, type: 1 });
    module.list?.forEach((room) => {
      items.push({ value: room, type: 0 })
    })
  })
  return [areas, items];
}

export class LiveHomeViewModel {

  static async getHomeData(): Promise<[AreaEntrance[], LiveGridItem[]] | ErrorMsg> {
    let url = `https://api.live.bilibili.com/xlive/web-interface/v1/index/getList?platform=android`;
    return httpRequestGet(url).then((result) => {
      if (result["code"] === 0) {
        return taskpool.execute(parseData, result)
      }
      return new ErrorMsg(result["message"]);
    }).then((result) => {
      return result as [AreaEntrance[], LiveGridItem[]];
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }
}