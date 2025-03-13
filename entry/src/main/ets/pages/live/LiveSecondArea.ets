import { ErrorMsg } from "../../model/ErrorMsg";
import { Room, SecondAreaBanner, SecondAreaTag } from "../../model/Live";
import { LiveAreaViewModel as vm } from "../../viewmodel/LiveAreaViewModel"
import { promptAction } from "@kit.ArkUI";
import { BaseDataSource } from "../../utils/BaseDataSource";
import Logger from "../../utils/Logger";


@Component
export struct LiveSecondArea{

  parentAreaId: number = 0;
  areaId: number = 0;

  @Consume("nav_stack") navStack: NavPathStack;

  @State banners: SecondAreaBanner[] = [];
  @State tags: SecondAreaTag[] = [];
  @State currentTag?: SecondAreaTag = undefined;
  rooms = new DataSource();

  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;
  private currentPage =1;

  async refresh(){
    this.currentPage = 1;
    let d = await vm.getSecondArea(this.parentAreaId, this.areaId,
      this.currentTag?.sort_type ?? "online", this.currentPage);
    if (d instanceof ErrorMsg) {
      promptAction.showToast({ message: d.message, duration: 2000 });
    } else {
      if (!this.currentTag && d.new_tags && d.new_tags.length > 0) {
        this.currentTag = d.new_tags[0];
      }
      this.banners = d.banner;
      this.tags = d.new_tags;
      this.rooms.reloadData(...d.list);
    }
    this.isRefreshing = false;
  }

  async loadMore(){
    let d = await vm.getSecondArea(this.parentAreaId, this.areaId,
      this.currentTag?.sort_type ?? "online", this.currentPage + 1);
    if (d instanceof ErrorMsg) {
      promptAction.showToast({ message: d.message, duration: 2000 });
    } else {
      this.currentPage++;
      this.rooms.addData(...d.list);
    }
    this.isLoading = false;
  }

  aboutToAppear(): void {
    this.refresh();
  }

  @Builder
  tagsBuilder() {
    Row() {
      ForEach(this.tags, (item: SecondAreaTag) => {
        Text(item.name)
          .fontSize(10)
          .fontColor(item.name == this.currentTag?.name ? $r('app.color.bili_pink') : $r('app.color.text_color2'))
          .lineHeight(10)
          .padding({ left: 8, top:5, right: 8, bottom: 4 })
          .margin({ left: 10, top: 10, bottom: 10 })
          .border({
            width: px2vp(1),
            color: item.name == this.currentTag?.name ? $r('app.color.bili_pink') : $r('app.color.text_color2'),
            radius: 10
          }).onClick(() => {
            this.currentTag = item;
            this.refresh();
          })
      })
    }.width('100%')
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {

        if (this.banners && this.banners.length > 0) {
          ListItem() {
            Swiper() {
              ForEach(this.banners, (item: SecondAreaBanner) => {
                Image(item.pic)
                  .width('100')
                  .height('100')
                  .objectFit(ImageFit.Cover)
              })
            }.width('100%')
            .height(100)
            .indicator(
              Indicator.dot()
                .right(0)
                .itemWidth(5)
                .itemHeight(5)
                .selectedItemWidth(5)
                .selectedItemHeight(5)
                .color(Color.White)
                .selectedColor($r('app.color.bili_pink'))
            )
            .borderRadius(4)
            .clip(true)
          }.margin({ left: 10, top: 10, right: 10 })
        }

        ListItemGroup({ header: this.tagsBuilder() }) {
          ListItem() {
            Grid() {
              LazyForEach(this.rooms, (item: Room, _index) => {
                GridItem() {
                  RoomItem({ data: item })
                }.reuseId("room_item")
                .onClick(() => {
                  this.navStack.pushPathByName("Room", item,
                    (popInfo) => {
                      Logger.info("Room", JSON.stringify(popInfo.result));
                    })
                })
              }, (item: Room) => {
                return `room_${item.roomid}`
              });
            }.width('100%').height('100%')
            .padding({ left: 8, right: 8 })
            .cachedCount(5)
            .columnsTemplate('1fr 1fr')
            .columnsGap(8)
            .rowsGap(8)
            .offset({ y: 8 })
            .scrollBar(BarState.Off)
            .onScrollIndex((_first, last) => {
              if (!this.isLoading && last > this.rooms.totalCount() - 5) {
                this.isLoading = true;
                this.loadMore();
              }
            }).nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
        }
      }.width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .sticky(StickyStyle.Header)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }.onRefreshing(() => {
      this.refresh();
    })
  }
}

@Reusable
@Component
struct RoomItem{

  @State data?: Room = undefined;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Room;
  }

  build() {
    RelativeContainer() {
      Image(this.data?.cover)
        .height(100)
        .width('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)
        .id("cover")
      Text(this.data?.title)
        .fontSize(14)
        .fontColor($r('app.color.text_color1'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .margin({ top: 8 })
        .alignRules({
          top: { anchor: "cover", align: VerticalAlign.Bottom }
        })
      Row() {
        Text(this.data?.uname)
          .layoutWeight(1)
          .fontSize(10)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .ellipsisMode(EllipsisMode.END)
          .margin({ left: 4 })
        Image(this.data?.watched_show?.icon)
          .width(12)
          .height(12)
        Text(this.data?.watched_show?.text_small)
          .fontSize(10)
          .fontColor(Color.White)
      }.width('100%')
      .padding(4)
      .linearGradient({ colors: [["#00000000", 0.0], ["#60000000", 1.0]] })
      .alignRules({
        left: { anchor: "cover", align: HorizontalAlign.Start },
        bottom: { anchor: "cover", align: VerticalAlign.Bottom }
      })
    }.height("auto")
  }
}

class DataSource extends BaseDataSource<Room> {
  generateKey(index: number): string {
    let d = this.getData(index);
    return `room_${d.roomid}`
  }
}