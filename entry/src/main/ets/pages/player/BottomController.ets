import { WindowUtil } from "../../utils/WindowUtil";
import { window } from "@kit.ArkUI";
import { AVPlayerController } from "../../utils/AVPlayerController";

export enum FullStyle {
  Normal,
  Land,
  Port
}

@Component
export struct  BottomController {
  
  @Link fullStyle: FullStyle;
  @Link ctrl: AVPlayerController;
  @Link isDragging: boolean;
  @Link dm: boolean
  @Link panEndTime: number;
  @Link isShowCtrl: boolean;
  onSliderChange?: (value: number, mode: SliderChangeMode) => void;

  @StorageProp("navHeight") navHeight: number = 0;
  @Consume("nav_stack") navStack: NavPathStack;

  build() {

    Column() {

      Row() {
        Image(this.ctrl.isPlaying ? $r('app.media.player_n_pause') : $r('app.media.player_n_play'))
          .width(30)
          .height(30)
          .margin({ left: 10 })
          .visibility(this.fullStyle === FullStyle.Normal ?
          Visibility.Visible : Visibility.None)
          .onClick(() => {
            if (this.ctrl.isPlaying) {
              this.ctrl.pause();
            } else {
              this.ctrl.play();
            }
          })
        Slider({
          value: this.isDragging ? this.panEndTime : this.ctrl.currentTime,
          max: this.ctrl.durationTime
        })
          .height(20)
          .layoutWeight(1)
          .trackThickness(2)
          .trackColor($r('app.color.player_slider_track'))
          .selectedColor(this.fullStyle === FullStyle.Port ? $r('app.color.player_slider_selected') : $r('app.color.bili_pink'))
          .blockColor($r('app.color.player_slider_selected'))
          .blockSize(this.fullStyle === FullStyle.Port ? { width: 8, height: 6 } : { width: 20, height: 19 })
          .blockStyle({
            type: this.fullStyle === FullStyle.Port ? SliderBlockType.SHAPE : SliderBlockType.IMAGE,
            image: $r("app.media.player_seek"),
            shape: new Rect().width(8).height(6).radius(3)
          }).margin({ left: 5, right: 5 })
          .onChange(this.onSliderChange)

        if (this.fullStyle === FullStyle.Normal) {
          Image($r('app.media.player_full_port'))
            .width(30)
            .height(30)
            .onClick(() => {
              animateTo({
                duration: 300,
              }, () => {
                this.fullStyle = FullStyle.Port;
              })
            })
          Image($r('app.media.player_full_land'))
            .width(30)
            .height(30)
            .margin({ left: 10, right: 10 })
            .onClick(() => {
              let windowUtil = WindowUtil.getInstance();
              windowUtil.disableWindowSystemBar();
              windowUtil.setLandscapeMultiWindow(true);
              windowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE);
            })
        }
      }

      Row() {
        Text()
          .layoutWeight(1)
          .height(36)
          .margin({ left: 15 })
          .borderRadius(18)
          .backgroundColor(Color.Gray)
          .onClick(() => {
            this.navStack.pushPathByName("Input", "");
          })
        Image($r('app.media.player_full_normal'))
          .width(30)
          .height(30)
          .margin({ left: 15 })
          .onClick(() => {
            animateTo({
              duration: 300,
            }, () => {
              this.fullStyle = FullStyle.Normal;
            })
          })
        Image($r('app.media.player_full_land'))
          .width(30)
          .height(30)
          .margin({ left: 15, right: 15 })
          .onClick(() => {
            let windowUtil = WindowUtil.getInstance();
            windowUtil.disableWindowSystemBar();
            windowUtil.setLandscapeMultiWindow(true);
            windowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE);
          })
      }
      .visibility(this.fullStyle === FullStyle.Port ?
      Visibility.Visible : Visibility.None)
      .margin({ bottom: AppStorage.get<number>("navHeight") })

      Row() {
        Image(this.ctrl.isPlaying ? $r('app.media.player_n_pause') : $r('app.media.player_n_play'))
          .width(32)
          .height(32)
          .margin({ left: 15 })
          .onClick(() => {
            if (this.ctrl.isPlaying) {
              this.ctrl.pause();
            } else {
              this.ctrl.play();
            }
          })
        Image($r('app.media.player_l_next'))
          .width(32)
          .height(32)
          .padding(5)
          .margin({ left: 15 })
        Image(this.dm ? $r('app.media.player_dm_on') : $r('app.media.player_dm_on'))
          .width(32)
          .height(32)
          .margin({ left: 15 })
        Text()
          .layoutWeight(1)
          .height(32)
          .backgroundColor(Color.Gray)
          .borderRadius(25)
          .onClick(() => {
            this.navStack.pushPathByName("Input", "");
          })
      }.height(50)
      .visibility(this.fullStyle === FullStyle.Land ?
      Visibility.Visible : Visibility.None)
    }.alignRules({
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
    }).linearGradient({ colors: [["#00000000", 0.0], ["#FF000000", 1.0]] })
    .visibility(this.fullStyle === FullStyle.Port || this.isShowCtrl ? Visibility.Visible : Visibility.None)
  }

}