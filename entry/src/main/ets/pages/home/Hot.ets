import { BVideo } from "../../model/BVideo";
import { ErrorMsg } from "../../model/ErrorMsg";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { HotViewModel as vm } from "../../viewmodel/HotViewModel";
import { promptAction } from "@kit.ArkUI";
import { isEmpty } from "../../utils/TextUtil";
import Logger from "../../utils/Logger";
import { formatData, parseView } from "../../utils/ParseUtil";

@Component({ freezeWhenInactive: true })
export struct Hot {

  @State isRefreshing: boolean = false;
  private data: DataSource = new DataSource();
  private currentPage: number = 1;

  async refresh() {
    this.currentPage = 1;
    let bvs = await vm.loadMore(this.currentPage);
    if (bvs instanceof ErrorMsg) {
      promptAction.showToast({ message: bvs.message, duration: 2000 })
    } else {
      this.data.reloadData(...bvs);
    }
    this.isRefreshing = false;
  }

  async loadMore() {
    let bvs = await vm.loadMore(this.currentPage + 1);
    if (bvs instanceof ErrorMsg) {
      promptAction.showToast({ message: bvs.message, duration: 2000 })
    } else if (bvs.length > 0) {
      this.currentPage++;
      this.data.addData(...bvs);
    }
    this.isRefreshing = false;
  }

  aboutToAppear(): void {
    this.refresh();
  }

  build() {
    Refresh({refreshing : $$this.isRefreshing}) {
      List(){
        LazyForEach(this.data, (item:BVideo) => {
          ListItem(){
            HotItem({ data: item });
          }.reuseId("HotItem")
        }, (item: BVideo, index: number) => {
          return item.bvid + index;
        })
      }.width('100%')
      .height('100%')
      .lanes({ minLength: 300, maxLength: 400 })
      .divider({
        strokeWidth: px2vp(1),
        color: Color.Gray,
        startMargin: 10,
        endMargin: 10
      })
      .scrollBar(BarState.Off)
      .cachedCount(3)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      }).onScrollIndex((_start, end, _center) => {
        if (end > this.data.totalCount() - 2) {
          this.loadMore();
        }
      })

    }.width('100%')
    .height('100%')
    .onRefreshing(() => this.refresh())
    .refreshOffset(60)
  }
}



@Reusable
@Component
struct HotItem{
  @State data: BVideo = new BVideo();

  aboutToReuse(params: Record<string, BVideo>): void {
    this.data = params.data;
  }

  build() {
    Row() {
      Image(this.data.pic)
        .layoutWeight(1)
        .height(100)
        .borderRadius(4)
      Column(){
        Text(this.data.title)
          .fontColor($r('app.color.text_color1'))
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .ellipsisMode(EllipsisMode.END)
        Blank().layoutWeight(1)
        Text(this.data.rcmd_reason?.content)
          .fontColor(Color.Orange)
          .fontSize(12)
          .maxLines(1)
          .borderColor(Color.Orange)
          .borderWidth(px2vp(1))
          .borderRadius(2)
          .padding({ left: 4, top: 2, right: 4, bottom: 1 })
          .visibility(isEmpty(this.data.rcmd_reason?.content) ? Visibility.None : Visibility.Visible)

        Row(){
          Image($r('app.media.hot_up'))
            .width(15)
            .height(12.5)
          Text(this.data.owner?.name)
            .fontColor($r('app.color.text_color2'))
            .fontSize(12)
            .maxLines(1)
        }.margin({ top: 3 })
        Row(){
          Image($r('app.media.hot_view'))
            .width(16)
            .height(16)
          Text(`${parseView(this.data.stat?.view)}观看 · ${formatData(this.data.pubdate)}`)
            .fontColor($r('app.color.text_color2'))
            .fontSize(12)
            .maxLines(1)
        }.margin({ top: 3 })
      }.layoutWeight(1)
      .height(100)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
    }.padding(10)
    .onClick(() => {
      AppStorage.get<NavPathStack>("nav_stack")?.pushPathByName("Player", this.data.bvid,
        (popInfo) => {
          Logger.info("Rec", JSON.stringify(popInfo.result));
        })
    })
  }
}

class DataSource extends BaseDataSource<BVideo> {
  generateKey(index: number): string {
    return this.getData(index).bvid + index;
  }
}