import { BVideo } from "../../model/BVideo";
import { FullStyle } from "./BottomController";
import { Replies } from "./Replies";


@Component
export struct  PortContent {
  
  @Link fullStyle: FullStyle;
  @Link data: BVideo;

  @State isShowReply: boolean = false;
  @StorageProp("deviceHeight") deviceHeight: number = 0;

  navHeight: number = AppStorage.get("navHeight") ?? 0;
  @Consume("nav_stack") navStack: NavPathStack;

  @Builder reply() {
    Column() {
      Replies({ bv: this.data })
    }
  }

  build() {
    if (this.fullStyle === FullStyle.Port) {
      Image($r('app.media.player_p_back'))
        .width(30)
        .height(30)
        .margin({
          left: 15,
          top: AppStorage.get<number>("statusHeight")
        }).onClick(() => {
          this.navStack.pop();
        })

      Column() {
        Image($r('app.media.player_like_n'))
          .width(36)
          .height(36)
          .rotate({
            centerX: '50%',
            centerY: '50%',
            angle: 180
          })
        Text(`${this.data.stat?.like}`)
          .fontColor(Color.White)
          .fontSize(12)
        Image($r('app.media.player_comment'))
          .width(36)
          .height(36)
          .margin({ top: 10 })
          .onClick(() => {
            this.isShowReply = true;
          }).bindSheet($$this.isShowReply, this.reply(), {
            showClose: false,
            backgroundColor: Color.White,
            detents: [SheetSize.MEDIUM, SheetSize.LARGE, SheetSize.MEDIUM],
            scrollSizeMode: ScrollSizeMode.CONTINUOUS
          }).backgroundColor(Color.Black)
        Text(`${this.data.stat?.reply}`)
          .fontColor(Color.White)
          .fontSize(12)
        Image($r('app.media.player_coin_n'))
          .width(36)
          .height(36)
          .margin({ top: 10 })
        Text(`${this.data.stat?.coin}`)
          .fontColor(Color.White)
          .fontSize(12)
        Image($r('app.media.player_collect_n'))
          .width(36)
          .height(36)
          .margin({ top: 10 })
        Text(`${this.data.stat?.favorite}`)
          .fontColor(Color.White)
          .fontSize(12)
        Image($r('app.media.player_share'))
          .width(36)
          .height(36)
          .margin({ top: 10 })
        Text(`${this.data.stat?.share}`)
          .fontColor(Color.White)
          .fontSize(12)
      }
      .alignRules({
        right: { anchor: '__container__', align: HorizontalAlign.End },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      }).margin({ bottom: 60 + this.navHeight, right: 15 })

      Text(this.data.title)
        .height(40)
        .fontSize(14)
        .fontColor(Color.White)
        .maxLines(2)
        .ellipsisMode(EllipsisMode.END)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        }).margin({
          bottom: 70 + this.navHeight,
          left: 10,
          right: 70
        }).id("p_title")
      Image(this.data.owner?.face)
        .width(50)
        .height(50)
        .borderRadius(25)
        .margin({ left: 10, bottom: 10 })
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          bottom: { anchor: 'p_title', align: VerticalAlign.Top }
        }).id("profile")
      Text(this.data.owner?.name)
        .fontColor(Color.White)
        .margin({ left: 5, top: 5 })
        .alignRules({
          left: { anchor: 'profile', align: HorizontalAlign.End },
          top: { anchor: 'profile', align: VerticalAlign.Top }
        })
      Text("1000粉丝")
        .fontSize(12)
        .fontColor(Color.White)
        .margin({ left: 5, bottom: 5 })
        .alignRules({
          left: { anchor: 'profile', align: HorizontalAlign.End },
          bottom: { anchor: 'profile', align: VerticalAlign.Bottom }
        })
    }
  }

}