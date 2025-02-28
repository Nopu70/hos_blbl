import { BVideo } from "../../model/BVideo";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { RecViewModel } from "ets/viewmodel/RecViewModel";
import { ErrorMsg } from "../../model/ErrorMsg";
import { promptAction } from "@kit.ArkUI";
import Logger from "../../utils/Logger";


@Component({ freezeWhenInactive: true })
export struct Rec {

  @State isRefreshing: boolean = false;
  private data: BVDataSource = new BVDataSource();
  private vm: RecViewModel = new RecViewModel();

  onDidBuild(): void {
    this.loadData();
  }

  async loadData() {
    let data = await this.vm.loadMore();
    if (data instanceof ErrorMsg) {
      promptAction.showToast({ message: data.message, duration: 2000 });
    } else if (data) {
      this.data.reloadData(...data);
    }
    this.isRefreshing = false;
  }

  build() {

    Refresh({refreshing : $$this.isRefreshing}) {
      List() {
        LazyForEach(this.data, (item:BVideo, _index) => {

          ListItem() {
            BVCardView({ data: item })
          }.reuseId("BVCardView")

        }, (item: BVideo) => {
          return item.bvid;
        })
      }.width('100%').height('100%')
      .padding({ left: 5, right: 5 })
      .lanes({ minLength: 180, maxLength: 400}, 5)
      .offset({ top: 5 })
      .contentEndOffset(10)
      .scrollBar(BarState.Off)
      .cachedCount(3)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })

      // Grid(this.scroller){
      //
      //
      //
      // }.width('100%')
      // .height('100%')
      // .padding({ left: 5, right: 5 })
      // .columnsTemplate("1fr 1fr")
      // .columnsGap(5)
      // .rowsGap(5)
      // .scrollBar(BarState.Off)
      // .supportAnimation(false)
      // .cachedCount(3)
      // .nestedScroll({
      //   scrollForward: NestedScrollMode.PARENT_FIRST,
      //   scrollBackward: NestedScrollMode.SELF_FIRST
      // })

    }.width('100%')
    .height('100%')
    .backgroundColor('#ffe5e5e5')
    .onRefreshing(() => this.loadData())
    .refreshOffset(60)
  }
}

@Component
@Reusable
struct BVCardView {
  @State data: BVideo = new BVideo()

  aboutToReuse(params: Record<string, BVideo>): void {
    this.data = params.data;
  }

  build() {
    Column() {
      Image(this.data.pic)
        .width('100%')
        .height(140)
      Text(this.data.title)
        .width('100%')
        .height(30)
        .margin({ top: 10 })
        .padding({ left: 8, right: 8 })
        .fontSize(14)
        .maxLines(2)
        .align(Alignment.TopStart)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
      Row() {
        Image($r('app.media.home_up'))
          .width(24)
          .height(24)
        Text(this.data.owner?.name)
          .layoutWeight(1)
          .margin({ left: 5 })
          .fontSize(12)
          .fontColor('#ff919191')
      }.margin({ top: 8, bottom: 8})
      .padding({ left: 8, right: 8 })
    }.width('100%')
    .margin({ bottom: 5 })
    .backgroundColor(Color.White)
    .borderRadius(4)
    .clip(true)
    .onClick(() => {
      AppStorage.get<NavPathStack>("nav_stack")?.pushPathByName("Player", this.data.bvid,
        (popInfo) => {
        Logger.info("Rec", JSON.stringify(popInfo.result));
      })
    })
  }
}

class BVDataSource extends BaseDataSource<BVideo> {
  generateKey(index: number): string {
    return this.getData(index).bvid + index;
  }
}