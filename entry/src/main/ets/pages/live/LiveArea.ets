import { LiveAreaViewModel as vm } from "../../viewmodel/LiveAreaViewModel"
import { ErrorMsg } from "../../model/ErrorMsg";
import { promptAction } from "@kit.ArkUI";
import { LiveArea as MArea } from "../../model/Live"
import { LiveSecondArea } from "./LiveSecondArea";
import Logger from "../../utils/Logger";

@Builder
export function entryBuilder(_: string, params: [areaId: number, parentId: number]) {
  LiveArea({ areaId: params[0], parentAreaId: params[1] })
}

@Component
struct LiveArea{

  areaId: number = 0;
  parentAreaId: number = 0;

  @Consume("nav_stack") navStack: NavPathStack;
  @StorageProp("deviceHeight") deviceHeight: number = 0
  @StorageProp("statusHeight") statusHeight: number = 0

  @State tabData?: MArea[] = undefined;
  @State mTabIndex: number = 0;
  @State yOffsets: number = 0.0;
  private tabCtrl = new TabsController();
  private scroller = new Scroller();

  @State indicatorStart: number = 0
  @State indicatorWidth: number = 20;
  private barInfo: [offset: number, width: number][] = [];
  private barCanScrollX = 0;
  private tabWidth = 0;

  @Builder
  tabBarItem(index: number, text: string) {
    Text(text)
      .height(40)
      .padding({ left: 10, right: 10 })
      .textAlign(TextAlign.Center)
      .onSizeChange((_o, n) => {
        let offset = 10;  //初始值包括padding left
        if (index !== 0) {
          offset = this.barInfo[index - 1][0] + this.barInfo[index - 1][1] + 20;
          if (index + 1 === this.tabData?.length) {
            this.barCanScrollX = offset - 10 + (n.width as number);
          }
        }
        this.barInfo[index] = [offset, (n.width as number - 20)];
      }).onClick(() => {
        this.tabCtrl.changeIndex(index);
      })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Image($r('app.media.back_black'))
              .padding(18)
              .width(50)
              .height(50)
              .onClick(() => {
                this.navStack.pop(true);
              })
            Text(this.tabData?.[0].parent_name ?? "")
              .fontColor($r('app.color.text_color1'))
          }.width('100%')
          .alignItems(VerticalAlign.Center)
          .padding({ top: this.statusHeight })
          .opacity(1 - this.yOffsets / this.statusHeight)
          .border({
            width: {
              bottom: px2vp(1)
            },
            color: Color.Gray
          })

          if (this.tabData) {
            Stack({ alignContent: Alignment.TopStart }) {
              Scroll(this.scroller) {
                Row() {
                  ForEach(this.tabData, (item: MArea, index) => {
                    this.tabBarItem(index, item.name)
                  })
                }
              }.scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .onWillScroll((xo, yo, state, source) => {
                if (source !== ScrollSource.SCROLLER && source !== ScrollSource.SCROLLER_ANIMATION) {
                  this.indicatorStart -= xo;
                }
              })
              Tabs({
                barPosition: BarPosition.Start,
                index: $$this.mTabIndex,
                controller: this.tabCtrl
              }) {
                ForEach(this.tabData, (item: MArea) => {
                  TabContent() {
                    LiveSecondArea({
                      parentAreaId: item.parent_id,
                      areaId: item.id
                    })
                  }
                })
              }.width('100%')
              .layoutWeight(this.deviceHeight - this.statusHeight - 40)
              .barHeight(0)
              .margin({ top: 40 })
              .divider({strokeWidth: px2vp(1), color: Color.Gray })
              .onSizeChange((_o, n) => {
                this.tabWidth = n.width as number;
                this.barCanScrollX = Math.max(this.barCanScrollX - this.tabWidth, 0);
                let scrollOffset = Math.min(this.barCanScrollX, Math.max(this.barInfo[this.mTabIndex][0] - 60, 0));
                this.scroller.scrollTo({
                  xOffset: scrollOffset,
                  yOffset: 0,
                  animation: false
                });
                this.setIndicatorAttr(this.barInfo[this.mTabIndex][0] - scrollOffset,
                  this.barInfo[this.mTabIndex][1]);
              })
              .onGestureSwipe((index, event) => {
                let next = index;
                let currentOffset = this.barInfo[index][0];
                let currentWidth = this.barInfo[index][1];
                if (event.currentOffset > 0) {
                  next--;
                } else if (event.currentOffset < 0) {
                  next++;
                }
                if (next < 0 || next >= this.barInfo.length) {
                  return;
                }
                let nextOffset = this.barInfo[next][0];
                let nextWidth = this.barInfo[next][1];

                let p = Math.abs(event.currentOffset / this.tabWidth);
                //指示器在current和next之间的偏移量
                let c_n_offset = (nextOffset - currentOffset) * p;

                //bar容器偏移量
                let scrollOffset = Math.min(this.barCanScrollX, Math.max(currentOffset + c_n_offset - 60, 0));
                this.scroller.scrollTo({
                  xOffset: scrollOffset,
                  yOffset: 0,
                  animation: false
                });

                let io = currentOffset - scrollOffset + c_n_offset;
                let iw = currentWidth + (nextWidth - currentWidth) * p;
                this.setIndicatorAttr(io, iw);
                Logger.debug("on_anim_start_GestureSwipe");
              }).onAnimationStart((_index, targetIndex, event) => {
                let duration = 300;
                if (event.velocity !== 0) {
                  duration = Math.min(duration, Math.abs(event.targetOffset * 1000 / event.velocity));
                }

                Logger.debug("on_anim_start");
                let scrollOffset = Math.min(this.barCanScrollX, Math.max(this.barInfo[targetIndex][0] - 60, 0));
                this.scroller.scrollTo({
                  xOffset: scrollOffset,
                  yOffset: 0,
                  animation: {
                    duration: 300,
                    curve: Curve.Linear
                  }
                });
                animateTo({ duration: duration, curve: Curve.Linear }, () => {
                  this.setIndicatorAttr(this.barInfo[targetIndex][0] - scrollOffset,
                    this.barInfo[targetIndex][1]);
                })
              })

              Stack()
                .height(3)
                .width(this.indicatorWidth)
                .borderRadius(1.5)
                .backgroundColor($r('app.color.bili_pink'))
                .margin({ left: this.indicatorStart, top: 37 })
            }.width('100%')
            .height(this.deviceHeight - this.statusHeight)
          }
        }
      }.scrollBar(BarState.Off)
      .onWillScroll((_, yOffset) => {
        this.yOffsets += yOffset;
      })
    }.hideTitleBar(true)
  }

  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }

  async loadTabData(){
    let d = await vm.getParentArea(this.parentAreaId);
    if (d instanceof ErrorMsg) {
      promptAction.showToast({ message: d.message, duration: 2000 });
    } else {
      d?.forEach((item, index) => {
        if (item.id == this.areaId) {
          this.mTabIndex = index;
        }
      })
      this.tabData = d;
    }
  }

  aboutToAppear(): void {
    this.loadTabData();
  }
}