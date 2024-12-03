import { BVideo } from "../model/BVideo";
import { ErrorMsg } from "../model/ErrorMsg";
import { httpRequestGet } from 'ets/utils/HttpUtil'


export class RecViewModel{

  async loadMore() : Promise<BVideo[] | ErrorMsg> {
    let url = "https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd";
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"]?.["item"] as BVideo[];
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  async refresh() : Promise<Array<BVideo> | null | ErrorMsg> {
    return this.loadMore();
  }

}