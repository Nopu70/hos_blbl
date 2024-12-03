import { ErrorMsg } from "../../model/ErrorMsg";
import { Reply } from "../../model/Reply";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { PlayerViewModel as vm } from "../../viewmodel/PlayerViewModel"
import { promptAction } from "@kit.ArkUI";
import { formatData, parseReply, parseUpLevel } from "../../utils/ParseUtil";
import { isEmpty } from "../../utils/TextUtil";
import { BVideo } from "../../model/BVideo";

@Component
export struct Replies {

  @Prop bv: BVideo;

  @State isRefreshing: boolean = false;
  @State @Watch("onSortChange") sortType: number = 1; //0：按时间1：按点赞数2：按回复数
  private dataSource = new DataSource();
  //由于列表默认有一个头部，所以在布局显示时会首先回调onScrollIndex，
  //没有这个头部就不会回调。页面初始化数据用的是loadMore方法，所以使用
  //nextPage而不是currentPage
  private nextPage = 1;

  onSortChange() {
    this.refresh();
  }

  async loadMore() {
    if (this.bv.bvid) {
      let rs = await vm.getReply(this.bv.bvid, this.nextPage, this.sortType);
      if (rs instanceof ErrorMsg) {
        promptAction.showToast({ message: rs.message, duration: 2000 })
      } else if (rs.length > 0) {
        this.nextPage++;
        this.dataSource.addData(...rs);
      }
    }
    this.isRefreshing = false;
  }

  async refresh() {
    if (this.bv.bvid) {
      let rs = await vm.getReply(this.bv.bvid, 1, this.sortType);
      if (rs instanceof ErrorMsg) {
        promptAction.showToast({ message: rs.message, duration: 2000 })
      } else if (rs.length > 0) {
        this.nextPage = 2;
        this.dataSource.reloadData(...rs);
      }
    }
    this.isRefreshing = false;
  }

  build() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List(){
        ListItem() {
          Row() {
            Text(this.sortType === 0 ? $r('app.string.reply_title1') : $r('app.string.reply_title2'))
              .fontSize(13)
              .layoutWeight(1)
            Image($r('app.media.comment_sort'))
              .width(14)
              .height(14)
            Text(this.sortType === 0 ? $r('app.string.reply_sort1') : $r('app.string.reply_sort2'))
              .fontSize(12)
              .fontColor($r('app.color.text_color2'))
              .margin({ left: 2 })
              .onClick(() => {
                if (this.sortType === 0) {
                  this.sortType = 1;
                } else {
                  this.sortType = 0;
                }
              })
          }.padding({ left: 10, top: 15, right: 10 })
        }

        LazyForEach(this.dataSource, (item: Reply) => {
          ListItem() {
            RepliesItem({ data: item, mid: this.bv.owner?.mid })
          }.reuseId("RepliesItem")
        }, (item: Reply, index: number) => {
          return `${item.rpid}_${index}`;
        })
      }.width('100%').height('100%')
      .cachedCount(3)
      .contentEndOffset(AppStorage.get("navHeight"))
      .scrollBar(BarState.Off)
      .onScrollIndex((_s, e, _c) => {
        if (e > this.dataSource.totalCount() - 3) {
          this.loadMore();
        }
      }).nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }.onRefreshing(() => this.refresh())
  }
}

@Reusable
@Component
struct RepliesItem{

  @Prop data: Reply;
  mid: number = 0;

  @State isFold: boolean = true;  //是否是折叠状态，是的话。评论折叠并显示展开
  @State isOver: boolean = false;

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as Reply;
    this.mid = params.mid as number;
    this.isOver = false;
    this.isFold = true;
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
          .maxLines(this.isOver && this.isFold ? 6 : 100)
          .onSizeChange((_oldValue, newValue) => {
            if (!this.isOver && newValue.height as number > 144) {
              this.isOver = true;
            }
          })
          Text(this.isFold ? "展开" : "收起")
            .width(40)
            .fontColor("#ff00699d")
            .fontSize(14.5)
            .lineHeight(24)
            .visibility(this.isOver ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.isFold = !this.isFold;
            })

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
          if ((this.data.replies?.length ?? 0) > 0) {
            Column() {
              ForEach(this.data.replies, (item: Reply) => {
                Text(`${item.member?.uname}: ${item.content?.message}`) {
                  Span(`${item.member?.uname}: `)
                    .fontSize(14.5)
                    .fontColor("#ff00699d")
                  ForEach(parseReply(item.content?.message, item.content?.emote), (item: string) => {
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
                }.lineHeight(24)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .ellipsisMode(EllipsisMode.END)
              })
              if (this.data.rcount > 3) {
                Text(`查看${this.data.rcount}条回复 >`)
                  .fontSize(12)
                  .fontColor("#ff00699d")
                  .margin({ top: 6 })
              }
            }.width('100%')
            .alignItems(HorizontalAlign.Start)
            .backgroundColor("#fff6f7f8")
            .padding(8)
            .margin({ top: 10 })
            .borderRadius(4)
          }
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