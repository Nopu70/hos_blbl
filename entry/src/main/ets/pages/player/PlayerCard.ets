import { BVDetail } from "../../model/BVDetail";
import { BVideo } from "../../model/BVideo";
import { BaseDataSource } from "../../utils/BaseDataSource";
import { formatData, parseView } from "../../utils/ParseUtil";


@Component
export struct PlayerCard{

  @Prop data: BVDetail;
  onItemClick: (bid: string) => void = () => {};

  @StorageProp("navHeight") navHeight: number = 0;
  private listData: DataSource = new DataSource(this.data?.Related);

  build() {
    List(){
      ListItem(){
        RelativeContainer() {
          Image(this.data?.View?.owner?.face)
            .width(50)
            .height(50)
            .borderRadius(25)
            .margin({ left: 10, top: 10 })
            .id("profile")
          Text(this.data?.View?.owner?.name)
            .fontSize(14)
            .fontColor($r('app.color.text_color1'))
            .margin({ left: 5, top: 5 })
            .alignRules({
              left: { anchor: 'profile', align: HorizontalAlign.End },
              top: { anchor: 'profile', align: VerticalAlign.Top }
            })
          Text(`${parseView(this.data?.Card?.follower)}粉丝`)
            .fontSize(12)
            .fontColor($r('app.color.text_color2'))
            .margin({ left: 5, bottom: 5 })
            .alignRules({
              left: { anchor: 'profile', align: HorizontalAlign.End },
              bottom: { anchor: 'profile', align: VerticalAlign.Bottom }
            })
          Row(){
            if (this.data?.Card?.following) {
              Image($r('app.media.player_card_followed'))
                .width(15)
                .height(15)
              Text($r('app.string.followed'))
                .fontSize(13)
                .fontColor(Color.White)
                .margin({ left: 3 })
            } else {
              Image($r('app.media.player_card_follow'))
                .width(15)
                .height(15)
              Text($r('app.string.follow'))
                .fontSize(13)
                .fontColor(Color.White)
                .margin({ left: 3 })
            }
          }.alignRules({
            center: { anchor: 'profile', align: VerticalAlign.Center },
            right:  { anchor: '__container__', align: HorizontalAlign.End }
          }).backgroundColor(this.data?.Card?.following ? $r('app.color.text_color2') : $r('app.color.bili_pink'))
          .margin({ right: 10 })
          .padding({ left: 10, right: 10 })
          .height(24)
          .borderRadius(12)
          Text(`${this.data?.View?.title}`)
            .fontColor($r('app.color.text_color1'))
            .margin({ left: 10, top: 20, right: 30 })
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              top: {anchor: 'profile', align: VerticalAlign.Bottom},
              right: { anchor: '__container__', align: HorizontalAlign.End }
            }).id("title")
          Image($r('app.media.hot_view'))
            .width(16)
            .height(16)
            .margin({ left: 10, top: 10 })
            .alignRules({
              left: { anchor: '__container__', align: HorizontalAlign.Start },
              top: { anchor: 'title', align: VerticalAlign.Bottom },
            }).id("view")
          Text(`${parseView(this.data?.View?.stat?.view)}`)
            .fontColor($r('app.color.text_color2'))
            .fontSize(12)
            .maxLines(1)
            .margin({ left: 3 })
            .alignRules({
              left: { anchor: 'view', align: HorizontalAlign.End },
              center: { anchor: 'view', align: VerticalAlign.Center }
            }).id("view_n")
          Image($r('app.media.player_card_dm'))
            .width(16)
            .height(16)
            .margin({ left: 5 })
            .alignRules({
              left: { anchor: 'view_n', align: HorizontalAlign.End },
              center: { anchor: 'view', align: VerticalAlign.Center }
            }).id("danmu")
          Text(`${this.data?.View?.stat?.danmaku}  ${formatData(this.data?.View?.pubdate, true)}`)
            .fontColor($r('app.color.text_color2'))
            .fontSize(12)
            .maxLines(1)
            .margin({ left: 2 })
            .alignRules({
              left: { anchor: 'danmu', align: HorizontalAlign.End },
              center: { anchor: 'view', align: VerticalAlign.Center }
            }).id("danmu_n")

          Column(){
            Image($r('app.media.player_card_like'))
              .width(22)
              .height(22)
            Text(parseView(this.data?.View?.stat?.like))
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .margin({ top: 5 })
          }.alignRules({
            top: { anchor: "view", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "dislike", align: HorizontalAlign.Start }
          }).margin({ top: 20, bottom: 10 })
          .chainMode(Axis.Horizontal, ChainStyle.SPREAD)
          .id("like")

          Column(){
            Image($r('app.media.player_card_dislike'))
              .width(22)
              .height(22)
              .margin({ top: 1 })
            Text(parseView(this.data?.View?.stat?.dislike))
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .margin({ top: 4 })
          }.alignRules({
            top: { anchor: "like", align: VerticalAlign.Top },
            left: { anchor: "like", align: HorizontalAlign.End },
            right: { anchor: "coin", align: HorizontalAlign.Start }
          }).id("dislike")

          Column(){
            Image($r('app.media.player_card_coin'))
              .width(22)
              .height(22)
            Text(parseView(this.data?.View?.stat?.coin))
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .margin({ top: 5 })
          }.alignRules({
            top: { anchor: "like", align: VerticalAlign.Top },
            left: { anchor: "dislike", align: HorizontalAlign.End },
            right: { anchor: "favorite", align: HorizontalAlign.Start }
          }).id("coin")

          Column(){
            Image($r('app.media.player_card_fav'))
              .width(22)
              .height(22)
            Text(parseView(this.data?.View?.stat?.favorite))
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .margin({ top: 5 })
          }.alignRules({
            top: { anchor: "like", align: VerticalAlign.Top },
            left: { anchor: "coin", align: HorizontalAlign.End },
            right: { anchor: "share", align: HorizontalAlign.Start }
          }).id("favorite")

          Column(){
            Image($r('app.media.player_card_share'))
              .width(22)
              .height(22)
            Text(parseView(this.data?.View?.stat?.share))
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .margin({ top: 5 })
          }.alignRules({
            top: { anchor: "like", align: VerticalAlign.Top },
            left: { anchor: "favorite", align: HorizontalAlign.End },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          }).id("share")
        }.height('auto')
      }
      ListItem(){
        Divider()
          .width('100%')
          .strokeWidth(px2vp(1))
          .color("#ffbbbbbb")
      }

      LazyForEach(this.listData, (item:BVideo, index: number) => {
        ListItem(){
          CardItem({
            data: item,
            onItemClick: this.onItemClick,
            isShowDivider: index !== this.listData.totalCount() - 1
          });
        }.reuseId("CardItem")
      }, (item: BVideo, index: number) => {
        return item.bvid + index;
      })

    }.width('100%')
    .height('100%')
    .contentEndOffset(this.navHeight)
  }
}

@Reusable
@Component
struct CardItem{
  @State data: BVideo = new BVideo();
  @State isShowDivider: boolean = false;
  onItemClick: (bid: string) => void = () => {};

  aboutToReuse(params: Record<string, Object>): void {
    this.data = params.data as BVideo;
    this.isShowDivider = params.isShowDivider as boolean;
  }

  build() {
    Column() {
      Row() {
        Image(this.data?.pic)
          .layoutWeight(5)
          .height(80)
          .borderRadius(4)
        Column(){
          Text(this.data?.title)
            .fontSize(14)
            .fontColor($r('app.color.text_color1'))
            .lineHeight(20)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)
          Blank().layoutWeight(1)
          Row(){
            Image($r('app.media.hot_up'))
              .width(15)
              .height(12.5)
            Text(this.data?.owner?.name)
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .maxLines(1)
          }.margin({ top: 3 })
          Row(){
            Image($r('app.media.hot_view'))
              .width(16)
              .height(16)
            Text(`${parseView(this.data?.stat?.view)}`)
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .maxLines(1)
            Image($r('app.media.player_card_dm'))
              .width(16)
              .height(16)
              .margin({ left: 5 })
            Text(`${parseView(this.data?.stat?.danmaku)}`)
              .fontColor($r('app.color.text_color2'))
              .fontSize(12)
              .maxLines(1)

          }.margin({ top: 3 })
        }.layoutWeight(9)
        .height(80)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
      }.padding(10)

      if (this.isShowDivider) {
        Divider()
          .width('100%')
          .strokeWidth(px2vp(1))
          .color("#ffd7d7d7")
          .margin({ left: 10 })
      }

    }.onClick(() => {
      // 多页面加载视频
      // AppStorage.get<NavPathStack>("nav_stack")?.pushPathByName("Player", this.data?.bvid,
      //   (popInfo) => {
      //     Logger.info("Rec", JSON.stringify(popInfo.result));
      //   })
      // 单页面加载视频
      this.onItemClick(this.data?.bvid);
    })
  }
}

class DataSource extends BaseDataSource<BVideo> {
  constructor(data?: BVideo[]) {
    super();
    if (data) {
      this.data?.splice(0, this.data?.length, ...data);
    }
  }
  generateKey(index: number): string {
    return this.getData(index).bvid + index;
  }
}