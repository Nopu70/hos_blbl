import { BVideo } from "../model/BVideo";
import { ErrorMsg } from "../model/ErrorMsg";
import { httpRequestGet } from 'ets/utils/HttpUtil'


export class HotViewModel{

  static async loadMore(page: number) : Promise<BVideo[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/web-interface/popular?ps=10&pn=${page}`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"]?.["list"] as BVideo[];
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

}