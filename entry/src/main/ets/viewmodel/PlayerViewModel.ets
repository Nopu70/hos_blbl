import { BVideo } from "../model/BVideo";
import { BVDetail } from "../model/BVDetail";
import { ErrorMsg } from "../model/ErrorMsg";
import { httpRequestGet } from 'ets/utils/HttpUtil'
import { VideoUrl } from "../model/VideoUrl";
import { Reply } from "../model/Reply";
import { JSON } from "@kit.ArkTS";


export class PlayerViewModel{

  static async loadVideo(id: string) : Promise<BVideo | ErrorMsg> {
    let url = `https://api.bilibili.com/x/web-interface/wbi/view?bvid=${id}`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as BVideo;
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async loadRelated(id: string) : Promise<BVideo[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/web-interface/archive/related?bvid=${id}`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as BVideo[];
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async loadDetail(bid: string) : Promise<BVDetail | ErrorMsg> {
    let url = `https://api.bilibili.com/x/web-interface/wbi/view/detail?bvid=${bid}`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as BVDetail;
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getUrl(cid: number, bid: string, qu?: number) : Promise<VideoUrl | ErrorMsg> {
    //&platform=html5&high_quality=1 (html5:手机web版, 1为允许获得高画质 PC端口获取视频流解析不了)
    let url = `https://api.bilibili.com/x/player/wbi/playurl?bvid=${bid}&cid=${cid}&platform=html5&high_quality=1&qn=64`;
    return httpRequestGet(url).then((result) => {
      let data = result?.["data"] as VideoUrl;
      return data!;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getReply(bid: string, pn: number, sort: number = 0) : Promise<Reply[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/v2/reply?type=1&oid=${bid}&sort=${sort}&pn=${pn}`;
    return httpRequestGet(url).then((result) => {
      if (result?.["code"] == 0) {
        let data: Reply[] = [];
        if (pn === 1) {
          let top = result?.["data"]?.["top_replies"] as Reply[];
          if (top && top.length > 0) {
            data.splice(0, 0, ...top);
          }
        }
        data.splice(data.length, 0, ...(result?.["data"]?.["replies"] as Reply[]));
        return data!;
      }
      return new ErrorMsg(`请求错误: ${result?.["message"]}`);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  static async getReplyReply(oid: number, root: number, pn: number, ps: number = 10) : Promise<Reply[] | ErrorMsg> {
    let url = `https://api.bilibili.com/x/v2/reply/reply?type=1&oid=${oid}&root=${root}&ps=${ps}&pn=${pn}`;
    return httpRequestGet(url).then((result) => {
      if (result?.["code"] == 0) {
        let data: Reply[] = [];
        if (pn === 1) {
          let root = result?.["data"]?.["root"] as Reply;
          if (root) {
            data.splice(0, 0, root);
          }
        }
        data.splice(data.length, 0, ...(result?.["data"]?.["replies"] as Reply[]));
        return data!;
      }
      return new ErrorMsg(`请求错误: ${result?.["message"]}`);
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }
}