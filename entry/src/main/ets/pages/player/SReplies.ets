import { ErrorMsg } from "../../model/ErrorMsg";
import { Reply } from "../../model/Reply";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { formatData, parseReply, parseUpLevel } from "../../utils/ParseUtil";
import { isEmpty } from "../../utils/TextUtil";
import { PlayerViewModel as vm } from "../../viewmodel/PlayerViewModel"
import { promptAction } from "@kit.ArkUI";

@Builder
export function entryBuilder(_: string, params: Reply) {
  SReplies({ reply: params });
}

@Component
struct SReplies{

  @Prop reply: Reply;
  @State rNavStack?: NavPathStack = undefined;
  @StorageProp("navHeight") navHeight: number = 0;

  private dataSource = new DataSource();
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;
  private currentPage: number = 1;

  async loadMore() {
    if (this.reply) {
      let rs = await vm.getReplyReply(this.reply.oid, this.reply.rpid, this.currentPage + 1);
      if (rs instanceof ErrorMsg) {
        promptAction.showToast({ message: rs.message, duration: 2000 })
      } else if (rs.length > 0) {
        this.currentPage++;
        this.dataSource.addData(...rs.slice(1));
      }
    }
    this.isLoading = false;
  }

  async refresh() {
    if (this.reply) {
      this.currentPage = 1;
      let rs = await vm.getReplyReply(this.reply.oid, this.reply.rpid, this.currentPage);
      if (rs instanceof ErrorMsg) {
        promptAction.showToast({ message: rs.message, duration: 2000 })
      } else if (rs.length > 0) {
        this.dataSource.reloadData(...rs.slice(1));
      }
    }
    this.isRefreshing = false;
  }

  aboutToAppear(): void {
    this.refresh();
  }

  build() {
    NavDestination() {

      Column() {
        Row() {
          Text($r('app.string.s_reply_title'))
            .fontSize(14.5)
            .fontColor($r('app.color.text_color1'))
            .margin({ left: 12 })
            .layoutWeight(1)
          Text("✖")
            .fontSize(18)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.rNavStack?.pop();
            })
        }.height(40)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        Divider()
          .color("#ffd7d7d7")
          .strokeWidth(px2vp(1))

        Refresh({ refreshing: $$this.isRefreshing }) {
          List() {
            LazyForEach(this.dataSource, (item: Reply) => {
              ListItem() {
                RepliesItem({ data: item, mid: this.reply.mid })
              }.reuseId("RepliesItem")
            }, (item: Reply, index: number) => {
              return `${item.rpid}_${index}`;
            })
          }.width('100%')
          .height('100%')
          .cachedCount(3)
          .scrollBar(BarState.Off)
          .onScrollIndex((_s, e, _c) => {
            if (!this.isLoading && e > this.dataSource.totalCount() - 3) {
              this.isLoading = true;
              this.loadMore();
            }
          }).nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          }).contentEndOffset(this.navHeight)
        }.layoutWeight(1)
        .onRefreshing(() => this.refresh())
      }
    }.onReady((context) => {
      this.rNavStack = context.pathStack;
    }).hideTitleBar(true)
  }
}


@Reusable
@Component
struct RepliesItem{

  @Prop data: Reply;
  mid: number = 0;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Reply;
  }

  build() {
    Column() {
      Row() {
        Image(this.data.member?.avatar)
          .width(30)
          .height(30)
          .borderRadius(15)
        Column() {
          Row() {
            Text(this.data.member?.uname)
              .fontSize(13)
              .fontColor(isEmpty(this.data.member?.vip.nickname_color) ? $r('app.color.text_color1') : this.data.member?.vip.nickname_color)
            Image(parseUpLevel(this.data.member?.level_info.current_level ?? 0))
              .width(20)
              .height(10)
              .margin({ left: 3 })
            if (this.data.mid === this.mid) {
              Image($r('app.media.home_up'))
                .width(18)
                .height(18)
                .margin({ left: 3 })
            }
          }
          Text(`${formatData(this.data.ctime)}  ${this.data.reply_control?.location}`)
            .fontSize(10)
            .fontColor($r('app.color.text_color2'))
            .margin({ top: 4 })
          Text() {
            if (this.data.reply_control?.is_up_top) {
              ImageSpan($r('app.media.comment_top'))
                .width(30)
                .height(18)
                .objectFit(ImageFit.Cover)
                .margin({ right: 4, bottom: 2 })
            }
            ForEach(parseReply(this.data.content?.message, this.data.content?.emote), (item: string) => {
              if (item.startsWith("http")) {
                ImageSpan(item)
                  .width(20)
                  .height(20)
                  .verticalAlign(ImageSpanAlignment.CENTER)
                  .objectFit(ImageFit.Cover)
              } else {
                Span(item)
                  .fontSize(14.5)
                  .fontColor($r('app.color.text_color1'))
              }
            })
          }.margin({ top: 10 })
          .lineHeight(24)

          Row() {
            Image(this.data.action === 1 ? $r('app.media.comment_like_s') : $r('app.media.comment_like'))
              .width(15)
              .height(15)
              .onClick(() => {
                if (this.data.action === 1) {
                  this.data.action = 0;
                } else {
                  this.data.action = 1;
                }
              })
            Text(`${this.data.like}`)
              .fontSize(12)
              .fontColor($r('app.color.text_color2'))
              .margin({ left: 3 })
            Image($r('app.media.comment_dislike'))
              .width(15)
              .height(15)
              .margin({ left: 15 })
            Image($r('app.media.comment_share'))
              .width(15)
              .height(15)
              .margin({ left: 15 })
            Image($r('app.media.comment_reply'))
              .width(15)
              .height(15)
              .margin({ left: 15 })
          }.alignItems(VerticalAlign.Bottom).margin({ top: 10 })
        }.layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }.alignItems(VerticalAlign.Top)
      .padding(12)
      Divider()
        .width('100%')
        .strokeWidth(px2vp(1))
        .color("#fff0f1f2")
    }
  }
}

class DataSource extends BaseDataSource<Reply> {
  generateKey(index: number): string {
    return `${this.getData(index).rpid}_${index}`;
  }
}