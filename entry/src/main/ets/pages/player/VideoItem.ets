import { BVideo } from "../../model/BVideo";
import { AVPlayerController } from "../../utils/AVPlayerController";
import { MGestureModifier } from "../../utils/MGestureModifier";
import { parseTimeS } from "../../utils/ParseUtil";
import { BottomController, FullStyle } from "./BottomController";
import { LandContent } from "./LandContent";
import { NormalContent } from "./NormalContent";
import { PortContent } from "./PortContent";

@Component
export struct VideoItem{

  @Link fullStyle: FullStyle;
  @Prop data: BVideo;
  @Prop @Watch("onCurrChange") currIndex: number;

  @StorageProp("deviceWidth") deviceWidth: number = 0;
  @State isShowCtrl: boolean = false;
  @State isSliderMoving: boolean = false;
  @State isSliderGesture: boolean = false;
  @State movingTime: string = "";
  @State isDmShow: boolean = true;
  @State playerCtrl: AVPlayerController = new AVPlayerController();
  @State panEndTime: number = 0;

  private componentCtrl = new XComponentController();
  private timeoutID?: number;
  private isShowCtrlBeforMoving = false;
  private panStart: number = 0;
  private panStartTime: number = 0;

  private doubleClickGesture = new TapGestureHandler({ count: 2})
    .onAction(() => {
    if (this.fullStyle === FullStyle.Port) {
    //点赞
    } else {
      if (this.playerCtrl.isPlaying) {
        this.playerCtrl.pause();
      } else {
        this.playerCtrl.play();
      }
    }
  });
  private clickGesture = new TapGestureHandler({ count: 1}).onAction(() => {
    if (this.fullStyle === FullStyle.Port) {
      if (this.playerCtrl.isPlaying) {
        this.playerCtrl.pause();
      } else {
        this.playerCtrl.play();
      }
    } else {
      if (this.isShowCtrl) {
        this.isShowCtrl = false;
      } else {
        this.showCtrl(5000);
      }
    }
  });
  private panHGesture = new PanGestureHandler({ direction: PanDirection.Horizontal })
    .onActionStart((event) => {
    this.panStart = event.offsetX;
    this.panStartTime = this.playerCtrl.currentTime;
    this.onSliderChange(this.panStartTime, SliderChangeMode.Begin);
    this.isSliderGesture = true;
  }).onActionUpdate((event) => {
    let newTime = (event.offsetX - this.panStart) *
    this.playerCtrl.durationTime / this.deviceWidth / 2 + this.panStartTime
    this.onSliderChange(newTime, SliderChangeMode.Moving);
    this.panEndTime = Math.min(Math.max(newTime, 0), this.playerCtrl.durationTime);
    this.onSliderChange(this.panEndTime, SliderChangeMode.Moving);
  }).onActionEnd(() => {
    this.onSliderChange(this.panEndTime, SliderChangeMode.End);
    this.isSliderGesture = false;
  });
  private panVGesture = new PanGestureHandler({ direction: PanDirection.Vertical })
    .onActionStart(() => {
    console.log("start_________")
  }).onActionUpdate(() => {

  }).onActionEnd(() => {

  })

  private nlGestureGroup = new GestureGroupHandler({
    mode: GestureMode.Exclusive,
    gestures: [this.doubleClickGesture, this.clickGesture, this.panHGesture, this.panVGesture]
  }).tag("player_gesture_group");
  private pGestureGroup = new GestureGroupHandler({
    mode: GestureMode.Exclusive,
    gestures: [this.doubleClickGesture, this.clickGesture, this.panHGesture]
  }).tag("player_gesture_group");

  onCurrChange() {
    this.playerCtrl.onCurrChange(this.data.index === this.currIndex)
  }

  aboutToDisappear(): void {
    this.playerCtrl.release();
  }

  onSliderChange = (value: number, mode: SliderChangeMode) => {
    switch (mode) {
      case SliderChangeMode.Begin:
        this.isShowCtrlBeforMoving = this.isShowCtrl;
        this.isShowCtrl = true;
        break;
      case SliderChangeMode.Moving:
        this.isSliderMoving = true;
        this.movingTime = `${parseTimeS(value)}/${this.playerCtrl.durationTimeString}`
        break;
      case SliderChangeMode.End:
        this.isSliderMoving = false;
        let seekTo = value * this.playerCtrl.duration / this.playerCtrl.durationTime;
        this.playerCtrl.currentTime = value;
        this.playerCtrl.seekTo(seekTo);
        if (this.isShowCtrlBeforMoving) {
          this.showCtrl(5000);
        } else {
          this.showCtrl(0);
        }
        break;
    }
  }


  showCtrl(time: number) {
    if (this.timeoutID) {
      clearTimeout(this.timeoutID);
    }
    this.timeoutID = setTimeout(() => {
      this.isShowCtrl = false;
      this.timeoutID = undefined;
    }, time);
    this.isShowCtrl = true;
  }

  build() {
    RelativeContainer() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.componentCtrl
      }).backgroundColor(Color.Black)
        .onLoad(() => {
        this.playerCtrl.init(this.componentCtrl.getXComponentSurfaceId());
        this.playerCtrl.setDataSource(this.data);
        this.onCurrChange();
      }).onSizeChange((_, newSize) => {
        let sw = vp2px(newSize.width as number);
        let sh = vp2px(newSize.height as number);
        let vw = this.data.dimension.width;
        let vh = this.data.dimension.height;
        let sAspectRatio = sw / sh;
        let vAspectRatio = vw / vh;
        if (sAspectRatio > vAspectRatio) {
          sw = sh * vAspectRatio;
        } else {
          sh = sw / vAspectRatio;
        }
        this.componentCtrl.setXComponentSurfaceRect({
          surfaceWidth: sw,
          surfaceHeight: sh
        });
      }).gestureModifier(new MGestureModifier(this.fullStyle === FullStyle.Port ? this.pGestureGroup : this.nlGestureGroup))
      .id("surface")

      Image(this.data.first_frame)
        .objectFit(ImageFit.Contain)
        .alignRules({
          left: { anchor: 'surface', align: HorizontalAlign.Start },
          top: { anchor: 'surface', align: VerticalAlign.Top },
          right: { anchor: 'surface', align: HorizontalAlign.End },
          bottom: { anchor: 'surface', align: VerticalAlign.Bottom }
        }).visibility(this.fullStyle === FullStyle.Port && !this.playerCtrl.startRenderFrame ? Visibility.Visible : Visibility.None)

      Text(this.movingTime)
        .width(120)
        .height(50)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .backgroundColor("#80000000")
        .borderRadius(5)
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        }).visibility(this.isSliderMoving ? Visibility.Visible : Visibility.None)

      NormalContent({
        fullStyle: this.fullStyle,
        isShowCtrl: this.isShowCtrl,
      })

      PortContent({
        fullStyle: this.fullStyle,
        data: this.data
      })

      LandContent({
        fullStyle: this.fullStyle,
        isShowCtrl: this.isShowCtrl
      })

      BottomController({
        fullStyle: this.fullStyle,
        ctrl: this.playerCtrl,
        isDragging: this.isSliderGesture,
        dm: this.isDmShow,
        onSliderChange: this.onSliderChange,
        panEndTime: this.panEndTime,
        isShowCtrl: this.isShowCtrl
      })

    }
  }
}