import { CircleShape, UIUtils } from "@kit.ArkUI";
import { Rec } from "ets/pages/home/Rec"
import { Hot } from "./Hot";
import { Lives } from "./Lives";


@Component({ freezeWhenInactive: true })
export struct Home {

  @State yOffsets: number = 0.0;
  @StorageProp("deviceHeight") deviceHeight: number = 0
  @StorageProp("statusHeight") statusHeight: number = 0
  @StorageProp("navHeight") navHeight: number = 0

  @State indicatorWidth: number = 20;
  @State indicatorStart: number = 0

  private initIndex: number = 1;
  @State private index: number = this.initIndex;
  private tabWidth: number = 0;
  private barItemInfo:[number, number][] = [];

  @Builder createTabBarItem(index: number, text: string) {
    Text(text)
      .fontColor(this.index === index ? $r('app.color.bili_pink') : $r('app.color.text_color1'))
      .textAlign(TextAlign.Center)
      .onAreaChange((_oldValue, newValue) => {
        this.barItemInfo[index] = [newValue.globalPosition.x as number, newValue.width as number]

        if (this.initIndex === index) {
          this.setIndicatorAttr(this.barItemInfo[this.initIndex][0],
            this.barItemInfo[this.initIndex][1])
        }
      })
  }

  build() {
    Scroll() {
      Column() {
        Row(){
          Image($r('app.media.main_tab3_s'))
            .width(40)
            .height(40)
            .clipShape(new CircleShape({ width: 40, height: 40 }))
          Row(){
            Image($r('app.media.home_search'))
              .width(20)
              .height(20)
              .margin({ left: 10 })
          }.height(36)
          .layoutWeight(1)
          .margin({ left: 20, right: 12 })
          .borderWidth(1)
          .borderColor($r('app.color.text_color1'))
          .borderRadius(18)

          Image($r('app.media.home_msg'))
            .width(36)
            .height(36)
            .padding(6)
        }.height(50)
        .padding({ left: 20, right: 12 })
        .margin({ top: this.statusHeight })
        .opacity(1 - this.yOffsets / 50)

        Stack({alignContent: Alignment.TopStart}){
          Tabs({
            barPosition: BarPosition.Start,
            index: this.initIndex
          }){
            TabContent(){
              Lives()
            }.tabBar(this.createTabBarItem(0, "直播"))
            TabContent(){
              Rec()
            }.tabBar(this.createTabBarItem(1, "推荐"))
            TabContent(){
              Hot()
            }.tabBar(this.createTabBarItem(2, "热门"))
          }.width('100%')
          .barHeight(36)
          .barWidth(200)
          .divider({strokeWidth: px2vp(1), color: Color.Gray })
          .edgeEffect(EdgeEffect.None)
          .onAreaChange((_o, n) => {
            this.tabWidth = n.width as number;
            // this.setIndicatorAttr(this.barItemInfo[this.index][0],
            //   this.barItemInfo[this.index][1])
          }).onGestureSwipe((index, event) => {
            let next = index;
            let cs = this.barItemInfo[index][0];
            let cw = this.barItemInfo[index][1];
            if (event.currentOffset > 0) {
              next--;
            } else if (event.currentOffset < 0) {
              next++;
            }
            if (next < 0 || next >= this.barItemInfo.length) {
              return;
            }
            let ns = this.barItemInfo[next][0];
            let nw = this.barItemInfo[next][1];
            let p = Math.abs(event.currentOffset / this.tabWidth);
            let is = cs + (ns - cs) * p;
            let iw = cw + (nw - cw) * p;
            this.setIndicatorAttr(is, iw);
          }).onAnimationStart((_index, targetIndex, event) => {
            this.index = targetIndex;
            this.initIndex = targetIndex;
            let duration = 300;
            if (event.velocity !== 0) {
              duration = Math.min(duration, Math.abs(event.targetOffset * 1000 / event.velocity));
            }
            animateTo({ duration: duration, curve: Curve.Linear }, () => {
              this.setIndicatorAttr(this.barItemInfo[targetIndex][0],
                this.barItemInfo[targetIndex][1]);
            })
          })

          Rect()
            .height(3)
            .width(this.indicatorWidth)
            .radius(1.5)
            .fill($r('app.color.bili_pink'))
            .margin({ left: this.indicatorStart, top: 33 })
        }.height(this.deviceHeight - this.statusHeight - this.navHeight - 50)
      }
    }.scrollBar(BarState.Off)
    .onWillScroll((_, yOffset) => {
      this.yOffsets += yOffset;
    })
  }

  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }
}