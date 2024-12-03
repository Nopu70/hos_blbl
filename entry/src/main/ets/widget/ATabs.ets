
// declare const ATabs: TabsInterface;

@Component
export struct ATabs {

  barPosition?: BarPosition;
  index?: number;
  controller?: TabsController;
  barHeight?: number;
  barWidth?: number;
  divider?: DividerStyle;
  scrollable?: boolean;
  animationMode?: AnimationMode;
  onChange?: (index: number) => void;
  @BuilderParam content: CustomBuilder;
  @Prop barItemInfo:[number, number][] = [];

  @State indicatorWidth: number = 20;
  @State indicatorStart: number = 0
  @State currIndex: number = 1;
  private tabWidth: number = 0;


  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }

  build() {
    Stack(){
      Tabs({
        barPosition: this.barPosition,
        index: this.index,
        controller: this.controller
      }){
        // this.content()
      }.barHeight(this.barHeight)
      .barWidth(this.barWidth)
      .divider(this.divider)
      .scrollable(this.scrollable)
      .animationMode(this.animationMode)
      .onChange(this.onChange)
      .barBackgroundColor(Color.Red)
      .edgeEffect(EdgeEffect.None)
      .onAreaChange((_o, n) => {
        this.tabWidth = n.width as number;
        this.setIndicatorAttr(this.barItemInfo[this.currIndex][0],
          this.barItemInfo[this.currIndex][1])
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
        this.currIndex = targetIndex;
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
  }
}