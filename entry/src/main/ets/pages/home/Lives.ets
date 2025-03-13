import { ErrorMsg } from "../../model/ErrorMsg";
import { AreaEntrance, LiveGridItem, ModuleInfo, Room } from "../../model/Live";
import { LiveHomeViewModel as vm } from "../../viewmodel/LiveHomeViewModel";
import { promptAction } from "@kit.ArkUI";
import { BaseDataSource } from "../../utils/BaseDataSource";
import Logger from "../../utils/Logger";

@Component
export struct Lives {

  @State isRefreshing: boolean = false;
  @State areas?: AreaEntrance[] = undefined;
  @State rooms: DataSource = new DataSource();

  @Consume("nav_stack") navStack: NavPathStack;

  async aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    let d = await vm.getHomeData();
    if (d instanceof ErrorMsg) {
      promptAction.showToast({ message: d.message, duration: 2000 })
    } else {
      this.areas = d[0];
      this.rooms.reloadData(...d[1])
    }
    this.isRefreshing = false;
  }

  build() {
    Refresh({refreshing : $$this.isRefreshing}) {
      List() {
        //类型分区
        if (this.areas) {
          ListItem() {
            Grid() {
              ForEach(this.areas.slice(0, 10), (item: AreaEntrance) => {
                GridItem() {
                  Column() {
                    Image(item.pic)
                      .width(50)
                      .height(50)
                    Text(item.title)
                      .fontSize(12)
                      .height(15)
                  }
                }.onClick(() => {
                  this.navStack.pushPathByName("LiveArea", [item.area_v2_id, item.area_v2_parent_id]);
                })
              })
            }.height(160)
            .padding(10)
            .margin(8)
            .borderRadius(4)
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .backgroundColor($r('app.color.main_card_bg'))
          }
        }


        //分区数据
        ListItem() {
          Grid() {
            LazyForEach(this.rooms, (item: LiveGridItem, _index) => {
              if (item.type === 1) {
                GridItem() {
                  Row() {
                    Image((item.value as ModuleInfo).pic).width(16).height(16)
                    Text((item.value as ModuleInfo).title)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .margin({ left: 4 })
                  }.width('100%')
                  .padding({ top: 10, bottom: 5 })
                }.columnStart(0)
                .columnEnd(1)
                .alignSelf(ItemAlign.Start)
              } else if (item.type === 0) {
                GridItem() {
                  RoomItem({ data: item.value as Room })
                }.reuseId("room_item")
                .onClick(() => {
                  AppStorage.get<NavPathStack>("nav_stack")?.pushPathByName("Room", item.value,
                    (popInfo) => {
                      Logger.info("Room", JSON.stringify(popInfo.result));
                    })
                })
              }
            }, (item: LiveGridItem) => {
              if (item.type === 0) {
                return `room_${(item.value as Room).roomid}`
              } else {
                return `room_${(item.value as ModuleInfo).id}`
              }
            });
          }.width('100%').height('100%')
          .padding({ left: 8, right: 8 })
          .cachedCount(5)
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .scrollBar(BarState.Off)
          .nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
        }
      }.width('100%').height('100%')
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }.backgroundColor($r('app.color.home_bg'))
    .onRefreshing(() => {
      this.loadData();
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
        .id("cover")
      Image(this.data?.face)
        .height(28)
        .width(28)
        .borderRadius(14)
        .margin({
          left: 8,
          top: 11
        }).alignRules({
        top: { anchor: "cover", align: VerticalAlign.Bottom },
      }).id("face")
      Text(this.data?.title)
        .fontSize(14)
        .fontColor($r('app.color.text_color1'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .alignRules({
          top: { anchor: "face", align: VerticalAlign.Top },
          left: { anchor: "face", align: HorizontalAlign.End },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        }).margin({ left: 4, right: 8 })
      Text(this.data?.uname)
        .fontSize(10)
        .fontColor($r('app.color.text_color2'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .alignRules({
          bottom: { anchor: "face", align: VerticalAlign.Bottom },
          left: { anchor: "face", align: HorizontalAlign.End },
        }).margin({ left: 4 })
    }.backgroundColor($r('app.color.main_card_bg'))
    .height(150)
    .borderRadius(4)
    .clip(true)
  }
}

class DataSource extends BaseDataSource<LiveGridItem> {
  generateKey(index: number): string {
    let d = this.getData(index);
    if (d.type === 0) {
      return `room_${(d.value as Room).roomid}`
    } else {
      return `room_${(d.value as ModuleInfo).id}`
    }
  }
}