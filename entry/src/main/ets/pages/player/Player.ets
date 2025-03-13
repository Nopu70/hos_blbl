import {  FullStyle } from "./BottomController";
import { promptAction, window } from "@kit.ArkUI";
import { WindowUtil } from "../../utils/WindowUtil";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { BVideo } from "../../model/BVideo";
import { VideoItem } from "./VideoItem";
import { PlayerViewModel as vm } from "../../viewmodel/PlayerViewModel"
import { ErrorMsg } from "../../model/ErrorMsg";
import { BVDetail } from "../../model/BVDetail";
import { PlayerCard } from "./PlayerCard";
import { Replies } from "./Replies";
import { AVSessionManager } from "../../utils/AVSessionManager";

@Builder
export function entryBuilder(_: string, params: string) {
  Player({ bid: params });
}

@Component
struct Player{

  @State @Watch("onFullChange") fullStyle: FullStyle = FullStyle.Normal;
  @State currSwiperIndex: number = 0;
  @State detail?: BVDetail | null = null;
  @Consume("nav_stack") navStack: NavPathStack;
  @Provide("r_nav_stack") rNavStack: NavPathStack = new NavPathStack();
  @StorageProp("deviceWidth") deviceWidth: number = 0;

  private barItemInfo:[number, number][] = [];
  private tabWidth: number = 0;
  @State indicatorWidth: number = 20;
  @State indicatorStart: number = 0
  @State currTabIndex: number = 0;

  bid: string = "";
  private dataSource = new DataSource();
  private aspect: number = 16 / 9;
  private context: Context = getContext(this);
  private windowUtil = WindowUtil.getInstance();

  @Builder createTabBarItem(index: number, text: string) {
    Text(text)
      .fontSize(14)
      .fontColor(this.currTabIndex === index ? $r('app.color.bili_pink') : $r('app.color.text_color2'))
      .textAlign(TextAlign.Center)
      .onAreaChange((_oldValue, newValue) => {
        this.barItemInfo[index] = [newValue.globalPosition.x as number, newValue.width as number]

        if (this.currTabIndex === index) {
          this.setIndicatorAttr(this.barItemInfo[this.currTabIndex][0],
            this.barItemInfo[this.currTabIndex][1])
        }
      })
  }

  build() {
    NavDestination(){
      Column() {
        Swiper() {
          LazyForEach(this.dataSource, (item: BVideo) => {
            VideoItem({
              fullStyle: this.fullStyle,
              data: item,
              currIndex: this.currSwiperIndex,
            })
          }, (item: BVideo, index: number) => {
            return item.bvid + index;
          })
        }.cachedCount(2)
        .indicator(false)
        .vertical(true)
        .loop(false)
        .disableSwipe(this.fullStyle != FullStyle.Port)
        .width('100%')
        .height(this.fullStyle === FullStyle.Normal ?
          this.deviceWidth / this.aspect : '100%')
        .onAnimationStart((_index, targetIndex) => {
          this.currSwiperIndex = targetIndex;
        })
        if (this.detail) {
          Navigation(this.rNavStack) {
            Stack({ alignContent: Alignment.TopStart }){
              Tabs(){
                TabContent(){
                  PlayerCard({ data: this.detail, onItemClick: async (bid: string) => {
                    this.reload(bid);
                  }})
                }.tabBar(this.createTabBarItem(0, "简介"))
                TabContent(){
                  Replies({ bv: this.detail?.View })
                }.tabBar(this.createTabBarItem(1, "评论"))
              }
              .barWidth(200)
              .barHeight(40)
              .divider({strokeWidth: px2vp(1), color: "#ffd7d7d7" })
              .onAreaChange((_o, n) => {
                this.tabWidth = n.width as number;
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
                this.currTabIndex = targetIndex;
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
                .height(2)
                .width(this.indicatorWidth)
                .radius(1)
                .fill($r('app.color.bili_pink'))
                .margin({ left: this.indicatorStart, top: 38 })
            }.width('100%')
          }.layoutWeight(1)
          .backgroundColor($r('app.color.main_card_bg'))
          .mode(NavigationMode.Stack)
          .hideTitleBar(true)
        }
      }
    }.hideTitleBar(true)
    .onBackPressed(() => {
      if (this.fullStyle === FullStyle.Land) {
        let windowUtil = WindowUtil.getInstance();
        windowUtil.enableWindowSystemBar();
        windowUtil.setLandscapeMultiWindow(false);
        windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
        return true;
      }
      return false;
    })
  }

  private setIndicatorAttr(start: number, width: number) {
    this.indicatorStart = start;
    this.indicatorWidth = width;
  }

  async aboutToAppear(): Promise<void> {
    this.context = getContext();
    let lastWindow = await window.getLastWindow(this.context);
    await lastWindow.setWindowKeepScreenOn(true)
    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        this.fullStyle = FullStyle.Land;
      } else {
        this.fullStyle = FullStyle.Normal;
      }
    })

    await this.loadDetail();
    if (this.detail?.View) {
      this.detail.View.index = 0;
      this.dataSource.reloadData(this.detail.View);
    }
  }

  aboutToDisappear(): void {
    AVSessionManager.getInstance().release();
  }

  async loadDetail(){
    let bd = await vm.loadDetail(this.bid);
    if (bd instanceof ErrorMsg) {
      promptAction.showToast({ message: bd.message, duration: 2000 });
    } else {
      this.detail = bd;
    }
  }

  async reload(bid: string) {
    this.bid = bid;
    this.detail = null;
    await this.loadDetail();
    if (this.detail) {
      let bVideo = (this.detail as BVDetail).View;
      if (bVideo) {
        bVideo.index = 0;
        this.dataSource.reloadData(bVideo)
      }
    }
  }

  async onFullChange() {
    if (this.fullStyle === FullStyle.Port) {
      if (this.detail?.Related) {
        this.detail.Related.forEach((value, index) => {
          value.index = index + 1;
        })
        this.dataSource.addData(...this.detail.Related);
      }
    } else {
      if (this.currSwiperIndex !== 0) {
        let currBv = this.dataSource.getData(this.currSwiperIndex);
        let firstBv = this.dataSource.getData(0);
        firstBv.index = -1;
        currBv.index = 0;
        this.currTabIndex = 0;
        this.bid = currBv.bvid;
        this.detail = null;
        this.loadDetail();
      }
      this.dataSource.clearOther(this.currSwiperIndex);
      this.currSwiperIndex = 0;
    }
  }

}



class DataSource extends BaseDataSource<BVideo> {
  generateKey(index: number): string {
    return this.getData(index).bvid + index;
  }
  clearOther(index: number){
    if (index === 0) {
      this.data.splice(1, this.data.length - 1);
      this.notifyDataDelete(1, this.data.length - 1);
    } else if (index > 0 && index < this.data.length - 1) {
      this.data.splice(0, index);
      this.notifyDataDelete(0, index);
      this.data.splice(1, this.data.length - 1);
      this.notifyDataDelete(1, this.data.length - 1);
    } else if (index === this.data.length - 1) {
      this.data.splice(0, this.data.length - 1);
      this.notifyDataDelete(0, this.data.length - 1);
    }
  }
}