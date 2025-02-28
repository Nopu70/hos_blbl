import { Home } from 'ets/pages/home/Home'
import { Dynamic } from './Dynamic';
import { Mine } from './Mine';

@Component
export struct Main {
  @StorageProp("navHeight") navHeight: number = 0;
  @State currentIndex: number = 0;

  @Builder
  TabBar(text: string, index: number, resN: ResourceStr, resS: ResourceStr){
    Column(){
      Image(index === this.currentIndex ? resS : resN)
        .width(25)
        .height(25)
      Divider()
        .height(3)
        .color(Color.Transparent)
      Text(text)
        .fontSize(12)
        .fontColor(index === this.currentIndex ? '#ffff6bae' : '#6B6B6B')
    }
  }

  build() {
    NavDestination(){
      Tabs({barPosition: BarPosition.End}) {

        TabContent() {
          Home()
        }.tabBar(this.TabBar("首页", 0, $r('app.media.main_tab1_n'), $r('app.media.main_tab1_s')))

        TabContent() {
          Dynamic()
        }.tabBar(this.TabBar("动态", 1, $r('app.media.main_tab2_n'), $r('app.media.main_tab2_s')))

        TabContent() {
          Mine({ mainIndex: this.currentIndex })
        }.tabBar(this.TabBar("我的", 2, $r('app.media.main_tab3_n'), $r('app.media.main_tab3_s')))

      }
      .padding({bottom: this.navHeight})
      .barHeight(50)
      .divider({strokeWidth: px2vp(1), color: "#ffc1c1c1"})
      .scrollable(false)
      .animationMode(AnimationMode.NO_ANIMATION)
      .onChange((index) => {
        this.currentIndex = index
      })
    }.hideTitleBar(true)
  }
}