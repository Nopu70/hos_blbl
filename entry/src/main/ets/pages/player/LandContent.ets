import { WindowUtil } from "../../utils/WindowUtil";
import { FullStyle } from "./BottomController";
import { window } from "@kit.ArkUI";


@Component
export struct LandContent {

  @Link fullStyle: FullStyle;
  @Link isShowCtrl: boolean;
  
  build() {

    Row() {
      Image($r('app.media.player_n_back'))
        .width(30)
        .height(30)
        .margin({ left: 15 })
        .onClick(() => {
          let windowUtil = WindowUtil.getInstance();
          windowUtil.enableWindowSystemBar();
          windowUtil.setLandscapeMultiWindow(false);
          windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
        })
      Text("是立刻搭街坊卡拉时间的浪费距离喀什觉得啊手动阀手动阀手动阀阿斯顿发射点发射点")
        .layoutWeight(1)
        .margin({ left: 10 })
        .fontSize(16)
        .fontColor(Color.White)
        .maxLines(1)
    }.height(75).width('100%')
    .backgroundColor(Color.Transparent)
    .linearGradient({ colors: [["#FF000000", 0.0], ["#00000000", 1.0]] })
    .visibility(this.fullStyle != FullStyle.Land || !this.isShowCtrl ?
    Visibility.None : Visibility.Visible)
  }
}