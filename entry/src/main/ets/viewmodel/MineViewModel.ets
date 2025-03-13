import { ErrorMsg } from "../model/ErrorMsg";
import { httpRequestGet } from 'ets/utils/HttpUtil'
import { Stat, User } from "../model/User";

export class MineViewModel{

  user?: User;
  stat?: Stat;

  loadUserInfo() {
    let url = "https://api.bilibili.com/x/web-interface/nav";
    httpRequestGet(url).then((result) => {
      let user = result["data"] as User;
      let l = result["data"]?.["level_info"]?.["current_level"] as number
      if (l) {
        switch (l) {
          case 0: user.level = $r('app.media.user_level_0'); break;
          case 1: user.level = $r('app.media.user_level_1'); break;
          case 2: user.level = $r('app.media.user_level_2'); break;
          case 3: user.level = $r('app.media.user_level_3'); break;
          case 4: user.level = $r('app.media.user_level_4'); break;
          case 5: user.level = $r('app.media.user_level_5'); break;
          case 6: user.level = $r('app.media.user_level_6'); break;
        }
      }
      this.user = user;
      if (user.isLogin && AppStorage.get<number>("uid") != user.mid) {
        AppStorage.setOrCreate("uid", user.mid);
      }
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

  async loadUserStat() {
    let url = "https://api.bilibili.com/x/web-interface/nav/stat";
    httpRequestGet(url).then((result) => {
      this.stat = result["data"] as Stat;
    }).catch((error: Error) => {
      return new ErrorMsg(error.message);
    });
  }

}