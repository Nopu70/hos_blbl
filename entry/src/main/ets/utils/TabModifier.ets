import { TabsModifier } from "@kit.ArkUI";

export class TabModifier implements AttributeModifier<TabsModifier> {
  barItemInfo:[number, number][] = [];
  @Track indicatorWidth: number = 20;
  @Track indicatorStart: number = 0
  @Track currIndex: number = 0;
  private tabWidth: number = 0;

  constructor(barItemInfo:[number, number][], index: number = 0) {
    this.barItemInfo = barItemInfo;
    this.currIndex = index;
  }

  applyNormalAttribute(instance: TabsModifier): void {
    instance.onAreaChange((_o, n) => {
      this.tabWidth = n.width as number;
      this.setIndicatorAttr(this.barItemInfo[this.currIndex][0],
        this.barItemInfo[this.currIndex][1])
    });
    instance.onGestureSwipe((index, event) => {
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
    });
    instance.onAnimationStart((_index, targetIndex, event) => {
      this.currIndex = targetIndex;
      let duration = 300;
      if (event.velocity !== 0) {
        duration = Math.min(duration, Math.abs(event.targetOffset * 1000 / event.velocity));
      }
      animateTo({ duration: duration, curve: Curve.Linear }, () => {
        this.setIndicatorAttr(this.barItemInfo[targetIndex][0],
          this.barItemInfo[targetIndex][1]);
      })
    });
  }

  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }

}