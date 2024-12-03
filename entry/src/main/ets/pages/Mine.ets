import { Stat, User } from "../model/User";
import { MineViewModel } from "../viewmodel/MineViewModel"

@Component
export struct Mine {

  @Prop @Watch("onMainIndexChange") mainIndex: number;

  @Consume("nav_stack") navStack: NavPathStack;
  @State vm: MineViewModel = new MineViewModel();

  onMainIndexChange() {
    if (this.mainIndex === 2 && !this.vm.user?.isLogin) {
      this.vm.loadUserInfo();
      this.vm.loadUserStat();
    }
  }

  aboutToAppear(): void {
    this.vm.loadUserInfo();
    this.vm.loadUserStat();
  }

  build() {

    Column() {
      if (this.vm.user?.isLogin) {
        MineLogin({user: this.vm.user, stat: this.vm.stat})
      } else if (this.vm.user && !this.vm.user.isLogin) {
        Button("登录")
          .width(250)
          .height(48)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.bili_pink'))
          .borderRadius(24)
          .onClick(() => {
            this.navStack.pushPathByName("Login", "", (popInfo) => {
              if (popInfo.result == 1) {
                this.vm.loadUserInfo();
                this.vm.loadUserStat();
              }
            });
          })
      }
    }

  }
}

@Component
struct MineLogin{

  @ObjectLink user: User;
  @ObjectLink stat: Stat;

  build() {
    RelativeContainer() {
      Image($r('app.media.ic_mine_daynight_day'))
        .width(36)
        .height(36)
        .padding(8)
        .alignRules({ end: { anchor: "__container__", align: HorizontalAlign.End } })
        .margin({ top: 50, right: 20 })

      Image(this.user.face)
        .width(60)
        .height(60)
        .borderRadius(35)
        .backgroundColor(Color.Blue)
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .margin({
          top: 80,
          left: 20
        }).id("face")

      Text(this.user.uname)
        .fontSize(16)
        .fontColor($r('app.color.text_color1'))
        .alignRules({
          top: { anchor: "face", align: VerticalAlign.Top },
          left: { anchor: "face", align: HorizontalAlign.End }
        }).margin({
          left: 30
        })
      Image(this.user.level)
        .width(27)
        .height(14)
        .alignRules({
          center: { anchor: "face", align: VerticalAlign.Center },
          left: { anchor: "face", align: HorizontalAlign.End }
        }).margin({
          left: 30
        })
      Text($r('app.string.coin'))
        .fontColor($r('app.color.text_color2'))
        .fontSize(12)
        .alignRules({
          bottom: { anchor: "face", align: VerticalAlign.Bottom },
          left: { anchor: "face", align: HorizontalAlign.End }
        }).margin({
          left: 30
        }).id("coin_lab")
      Text(`${this.user.money}`)
        .fontColor($r('app.color.text_color2'))
        .fontSize(12)
        .alignRules({
          center: { anchor: "coin_lab", align: VerticalAlign.Center },
          left: { anchor: "coin_lab", align: HorizontalAlign.End }
        }).margin({
          left: 5
        })
      Image($r('app.media.ic_mine_arrow_right'))
        .width(12)
        .height(12)
        .alignRules({
          center: { anchor: "face", align: VerticalAlign.Center },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        }).margin({
          right: 20
        }).id("space_arrow")
      Text($r('app.string.space'))
        .fontColor($r('app.color.text_color2'))
        .fontSize(12)
        .alignRules({
          center: { anchor: "space_arrow", align: VerticalAlign.Center },
          right: { anchor: "space_arrow", align: HorizontalAlign.Start }
        }).margin({
          left: 5
        })

      Column() {
        Text(`${this.stat.dynamic_count}`)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor($r('app.color.text_color1'))
        Text($r('app.string.dynamic'))
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontColor($r('app.color.text_color2'))
          .margin({ top: 3 })
      }.width(40)
      .alignRules({
        top: { anchor: "face", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "divider1", align: HorizontalAlign.Start }
      }).margin({ top: 30 })
      .chainMode(Axis.Horizontal, ChainStyle.SPREAD)
      .id("dynamic")

      Divider()
        .height(36)
        .vertical(true)
        .alignRules({
          center: { anchor: "dynamic", align: VerticalAlign.Center },
          left: { anchor: "dynamic", align: HorizontalAlign.End },
          right: { anchor: "follow", align: HorizontalAlign.Start }
        }).id("divider1")

      Column() {
        Text(`${this.stat.following}`)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor($r('app.color.text_color1'))
        Text($r('app.string.follow'))
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontColor($r('app.color.text_color2'))
          .margin({ top: 3 })
      }.width(40)
      .alignRules({
        top: { anchor: "dynamic", align: VerticalAlign.Top },
        left: { anchor: "divider1", align: HorizontalAlign.End },
        right: { anchor: "divider2", align: HorizontalAlign.Start }
      }).id("follow")

      Divider()
        .height(36)
        .vertical(true)
        .alignRules({
          center: { anchor: "dynamic", align: VerticalAlign.Center },
          left: { anchor: "follow", align: HorizontalAlign.End },
          right: { anchor: "fans", align: HorizontalAlign.Start }
        }).id("divider2")

      Column() {
        Text(`${this.stat.follower}`)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor($r('app.color.text_color1'))
        Text($r('app.string.fans'))
          .textAlign(TextAlign.Center)
          .fontSize(12)
          .fontColor($r('app.color.text_color2'))
          .margin({ top: 3 })
      }.width(40)
      .alignRules({
        top: { anchor: "dynamic", align: VerticalAlign.Top },
        left: { anchor: "divider2", align: HorizontalAlign.End },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      }).id("fans")

      Column(){
        Image($r('app.media.ic_mine_offline'))
          .width(30)
          .height(30)
        Text($r('app.string.offline'))
          .fontSize(12)
          .fontColor($r('app.color.text_color1'))
          .margin({ top: 10 })
      }.alignRules({
        top: { anchor: "dynamic", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start },
        right: { anchor: "history", align: HorizontalAlign.Start }
      }).margin({ top: 50 })
      .chainMode(Axis.Horizontal, ChainStyle.SPREAD)
      .id("offline")

      Column(){
        Image($r('app.media.ic_mine_history'))
          .width(30)
          .height(30)
        Text($r('app.string.history'))
          .fontSize(12)
          .fontColor($r('app.color.text_color1'))
          .margin({ top: 10 })
      }.alignRules({
        top: { anchor: "offline", align: VerticalAlign.Top },
        left: { anchor: "offline", align: HorizontalAlign.End },
        right: { anchor: "favorite", align: HorizontalAlign.Start }
      }).id("history")

      Column(){
        Image($r('app.media.ic_mine_favorite'))
          .width(30)
          .height(30)
        Text($r('app.string.collect'))
          .fontSize(12)
          .fontColor($r('app.color.text_color1'))
          .margin({ top: 10 })
      }.alignRules({
        top: { anchor: "offline", align: VerticalAlign.Top },
        left: { anchor: "history", align: HorizontalAlign.End },
        right: { anchor: "watchlater", align: HorizontalAlign.Start }
      }).id("favorite")

      Column(){
        Image($r('app.media.ic_mine_watchlater'))
          .width(30)
          .height(30)
        Text($r('app.string.watch_later'))
          .fontSize(12)
          .fontColor($r('app.color.text_color1'))
          .margin({ top: 10 })
      }.alignRules({
        top: { anchor: "offline", align: VerticalAlign.Top },
        left: { anchor: "favorite", align: HorizontalAlign.End },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      }).id("watchlater")
    }
  }
}