import { TypeItem } from "./TypeItem";

@Component({ freezeWhenInactive: true })
export struct Dynamic {


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

  @Builder createTabBarItem(index: number, text: ResourceStr) {
    Text(text)
      .fontColor(this.index === index ? $r('app.color.bili_pink') : $r('app.color.text_color1'))
      .textAlign(TextAlign.Center)
      .onAreaChange((_oldValue, newValue) => {
        this.barItemInfo[index] = [newValue.globalPosition.x as number, newValue.width as number];

        if (this.initIndex === index) {
          this.setIndicatorAttr(this.barItemInfo[this.initIndex][0],
            this.barItemInfo[this.initIndex][1]);
        }
      })
  }

  build() {
    Stack({alignContent: Alignment.TopStart}){
      Tabs({
        barPosition: BarPosition.Start,
        index: this.initIndex
      }){
        TabContent(){
          TypeItem({ type: "video" })
        }.tabBar(this.createTabBarItem(0, $r('app.string.dy_tab1')))
        TabContent(){
          TypeItem({ type: "all" })
        }.tabBar(this.createTabBarItem(1, $r('app.string.dy_tab2')))
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
    }
    .height('100%')
    .margin({ top: this.statusHeight })
  }

  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }

}