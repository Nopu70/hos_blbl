import { DyUpper } from "../../model/DyUpper";
import { ErrorMsg } from "../../model/ErrorMsg";
import { DynamicViewModel as vm } from "../../viewmodel/DynamicViewModel";
import { promptAction } from "@kit.ArkUI";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { DrawItem, Dynamic, RichTextNode } from "../../model/Dynamic";
import Logger from "../../utils/Logger";


@Component({ freezeWhenInactive: true })
export struct TypeItem {

  type: string = "all";
  @State hostMid: number = 0;

  @State isRefreshing: boolean = false;
  @State upList: DyUpper[] = [];
  private dataSource = new DataSource();

  async loadUpList() {
    let data = await vm.getUpList();
    if (data instanceof ErrorMsg) {
      promptAction.showToast({ message: data.message, duration: 2000 });
    } else if (data) {
      this.upList.splice(0, this.upList.length, ...data);
    }
  }

  async refresh() {
    let data = await vm.getDynamics(`${this.hostMid}`, this.type);
    if (data instanceof ErrorMsg) {
      promptAction.showToast({ message: data.message, duration: 2000 })
    } else if (data.length > 0) {
      this.dataSource.reloadData(...data);
    }
    this.isRefreshing = false;
  }

  aboutToAppear(): void {
    this.loadUpList();
    this.refresh();
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ListItem() {
          Column() {
            Text($r('app.string.dy_upl_title'))
              .fontColor($r('app.color.text_color1'))
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .backgroundColor($r('app.color.main_card_bg'))
              .padding(10)

            Row() {
              ForEach(this.upList, (item: DyUpper) => {
                Column() {
                  Image(item.face)
                    .width(50)
                    .height(50)
                    .border({
                      width: 1,
                      color: this.hostMid == item.mid ? $r('app.color.bili_pink') : Color.Transparent,
                      radius: 25
                    })
                    .clip(true)
                  Text(item.uname)
                    .fontColor(this.hostMid == item.mid
                      ? $r('app.color.bili_pink') : $r('app.color.text_color1'))
                    .fontSize(10)
                    .textAlign(TextAlign.Center)
                    .margin({ top: 8 })
                }.width(70)
                .onClick(() => {
                  if (this.hostMid == item.mid) {
                    this.hostMid = 0;
                  } else {
                    this.hostMid = item.mid;
                  }
                  this.refresh();
                })
              })
            }.width('100%')
            .padding(10)
            .backgroundColor($r('app.color.main_card_bg'))
            .alignItems(VerticalAlign.Top)
          }.width('100%')
          .margin({ bottom: 10 })
        }

        LazyForEach(this.dataSource, (item: Dynamic) => {
          if (item.type == "DYNAMIC_TYPE_WORD") {
            ListItem() {
              DynamicItemWord({ data: item })
            }.reuseId("dynamic_item_word")
          } else if (item.type == "DYNAMIC_TYPE_DRAW") {
            ListItem() {
              DynamicItemDraw({ data: item })
            }.reuseId("dynamic_item_draw")
          } else if (item.type == "DYNAMIC_TYPE_AV") {
            ListItem() {
              DynamicItemAV({ data: item })
            }.reuseId("dynamic_item_ab")
          }
        }, (item: Dynamic, index) => {
          return `${item.id_str}_${index}`;
        })
      }.width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }.backgroundColor($r('app.color.home_bg'))
    .onRefreshing(() => {
      this.loadUpList();
      this.refresh();
    })
  }
}

@Reusable
@Component
struct DynamicItemWord {

  @Prop data: Dynamic;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Dynamic;
  }

  build() {
    Column() {
      Row() {
        Image(this.data.modules.module_author.face)
          .width(40)
          .height(40)
          .borderRadius(20)
          .clip(true)
        Column() {
          Text(this.data.modules.module_author.name)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Text(`${this.data.modules.module_author.pub_time}·${this.data.modules.module_author.pub_action}`)
            .fontSize(12)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
        }.height(40)
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
      }

      Text() {
        ForEach(this.data.modules.module_dynamic.desc.rich_text_nodes, (item: RichTextNode) => {
          if (item.type == "RICH_TEXT_NODE_TYPE_TEXT") {
            Span(item.text)
              .fontSize(16)
              .fontColor($r('app.color.text_color1'))
          } else if (item.type == "RICH_TEXT_NODE_TYPE_EMOJI") {
            ImageSpan(item.emoji.icon_url)
              .width(20)
              .height(20)
              .verticalAlign(ImageSpanAlignment.CENTER)
              .objectFit(ImageFit.Cover)
          }
        })
      }.margin({ top: 10 })
      .lineHeight(24)

    }.width('100%')
    .padding(10)
    .margin({ bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.main_card_bg'))
  }
}

@Reusable
@Component
struct DynamicItemDraw {

  @Prop data: Dynamic;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Dynamic;
  }

  build() {
    Column() {
      Row() {
        Image(this.data.modules.module_author.face)
          .width(40)
          .height(40)
          .borderRadius(20)
          .clip(true)
        Column() {
          Text(this.data.modules.module_author.name)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Text(`${this.data.modules.module_author.pub_time}·${this.data.modules.module_author.pub_action}`)
            .fontSize(12)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
        }.height(40)
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
      }

      Text() {
        ForEach(this.data.modules.module_dynamic.desc.rich_text_nodes, (item: RichTextNode) => {
          if (item.type == "RICH_TEXT_NODE_TYPE_TEXT") {
            Span(item.text)
              .fontSize(16)
              .fontColor($r('app.color.text_color1'))
          } else if (item.type == "RICH_TEXT_NODE_TYPE_EMOJI") {
            ImageSpan(item.emoji.icon_url)
              .width(20)
              .height(20)
              .verticalAlign(ImageSpanAlignment.CENTER)
              .objectFit(ImageFit.Cover)
          }
        })
      }.margin({ top: 10 })
      .lineHeight(24)

      if (this.data.modules.module_dynamic.major.draw.items.length === 1) {
        Image(this.data.modules.module_dynamic.major.draw.items[0].src)
          .width(240)
          .height(240 / this.data.modules.module_dynamic.major.draw.items[0].width * this.data.modules.module_dynamic.major.draw.items[0].height)
          .margin({ top: 10 })
          .borderRadius(3)
          .clip(true)
      }
      if (this.data.modules.module_dynamic.major.draw.items.length > 1) {
        Grid() {
          ForEach(this.data.modules.module_dynamic.major.draw.items, (item: DrawItem) => {
            GridItem() {
              Image(item.src)
                .aspectRatio(1)
                .borderRadius(3)
                .clip(true)
            }
          })
        }.width('100%')
        .padding({ left: 8, right: 8 })
        .margin({ top: 10 })
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
      }

    }.width('100%')
    .padding(10)
    .margin({ bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.main_card_bg'))
  }
}


@Reusable
@Component
struct DynamicItemAV {

  @Prop data: Dynamic;
  @Consume navStack: NavPathStack;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Dynamic;
  }

  build() {
    Column() {
      Row() {
        Image(this.data.modules.module_author.face)
          .width(40)
          .height(40)
          .borderRadius(20)
          .clip(true)
        Column() {
          Text(this.data.modules.module_author.name)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Text(`${this.data.modules.module_author.pub_time}·${this.data.modules.module_author.pub_action}`)
            .fontSize(12)
            .fontColor($r('app.color.text_color1'))
            .fontWeight(FontWeight.Bold)
        }.height(40)
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
      }

      RelativeContainer() {
        Image(this.data.modules.module_dynamic.major.archive.cover)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
        Text(`${this.data.modules.module_dynamic.major.archive.duration_text}  ${this.data.modules.module_dynamic.major.archive.stat.play}观看  ${this.data.modules.module_dynamic.major.archive.stat.danmaku}弹幕`)
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor($r('sys.color.mask_fourth'))
          .alignRules({
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          }).margin({ left: 10, bottom: 10 })
          .padding(3)
          .borderRadius(2)
          .clip(true)

      }.width('100%')
      .height(200)
      .margin({ top: 10 })
      .borderRadius(3)
      .clip(true)

      Text(this.data.modules.module_dynamic.major.archive.title)
        .width('100%')
        .fontSize(15)
        .fontColor($r('app.color.text_color1'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .margin({ top: 10, bottom: 10 })

    }.width('100%')
    .padding(10)
    .margin({ bottom: 10 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.main_card_bg'))
    .onClick(() => {
      this.navStack.pushPathByName("Player", this.data.modules.module_dynamic.major.archive.bvid,
        (popInfo) => {
          Logger.info("Rec", JSON.stringify(popInfo.result));
        })
    })
  }
}


class DataSource extends BaseDataSource<Dynamic> {
  generateKey(index: number): string {
    return `${this.getData(index).id_str}_${index}`;
  }
}