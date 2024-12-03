import { Main } from './Main';



@Entry
@Component
struct Index {

  @Provide("nav_stack") navStack: NavPathStack = new NavPathStack();
  @StorageProp("navHeight") navHeight: number = 0;

  aboutToAppear(): void {
    AppStorage.setOrCreate("nav_stack", this.navStack);
  }

  build() {
    Navigation(this.navStack) {
      Main()
    }.mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}