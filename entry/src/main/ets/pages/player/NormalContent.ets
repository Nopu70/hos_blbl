import { FullStyle } from "./BottomController";


@Component
export struct  NormalContent {

  @Link fullStyle: FullStyle;
  @Link isShowCtrl: boolean;
  @Consume("nav_stack") navStack: NavPathStack;
  
  build() {
    Row() {
      Image($r('app.media.player_n_back'))
        .width(30)
        .height(30)
        .margin({ left: 15 })
        .onClick(() => {
          this.navStack.pop(true);
        })
      // Image($r('app.media.player_n_home'))
      //   .width(30)
      //   .height(30)
      //   .margin({ left: 10 })
    }.width('100%')
    .height(30 + (AppStorage.get<number>("statusHeight") ?? 0))
    .alignItems(VerticalAlign.Bottom)
    .linearGradient({ colors: [["#FF000000", 0.0], ["#00000000", 1.0]] })
    .visibility(this.fullStyle != FullStyle.Normal || !this.isShowCtrl ?
    Visibility.None : Visibility.Visible)
  }
  
}