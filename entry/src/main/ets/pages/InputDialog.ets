import { window } from "@kit.ArkUI";

@Builder
export function entryBuilder(_: string, params: string) {
  InputDialog();
}

@Component
struct InputDialog {

  @State keyBoardHeight: number = 0;
  @State isEmojiKeyboard: boolean = false;

  private ctrl = new RichEditorController();

  @StorageProp("navHeight") navHeight: number = 0;
  @Consume("nav_stack") navStack: NavPathStack;

  aboutToAppear(): void {
    window.getLastWindow(getContext()).then((window) => {
      window.on("keyboardHeightChange", (h) => {
        if (h === 0) {
          if (!this.isEmojiKeyboard) {
            this.navStack.pop();
          }
        } else {
          this.keyBoardHeight = px2vp(h);
        }
      })
    })
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext()).then((window) => {
      window.off("keyboardHeightChange");
    })
  }

  getEmojiList(): Resource[] {
    let list = new Array<Resource>(105);
    for (let i = 0; i < 105; i++) {
      list[i] = $r(`app.media.expression_${i + 1}`)
    }
    return list;
  }

  @Builder
  emojiKeyBoard() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Grid() {
        ForEach(this.getEmojiList(), (item: Resource, index) => {
          GridItem() {
            Image(item)
              .width(40)
              .height(40)
              .margin(index === 104 ? { bottom: this.navHeight + 80 } : undefined)
              .onClick(() => {
                this.ctrl.addImageSpan(item, {
                  offset: this.ctrl.getCaretOffset(),
                  imageStyle: {
                    size: [25, 25],
                    layoutStyle: {
                      margin: { top: 5 }
                    }
                  }
                });
              })
          }
        })
      }
      .width('100%')
      .height('100%')
      .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
      .columnsGap(5)
      .rowsGap(5)
      .scrollBar(BarState.Off)
      Image($r('app.media.input_backspace'))
        .width(50)
        .height(30)
        .padding({ left:12, top: 4, right: 16, bottom: 4 })
        .margin({ right: 20, bottom: this.navHeight + 20 })
        .backgroundColor(Color.White)
        .borderRadius(5)
        .onClick(() => {
          this.ctrl.deleteSpans({
            start: this.ctrl.getCaretOffset() - 1,
            end: this.ctrl.getCaretOffset()
          })
        })
    }.height(this.keyBoardHeight)
    .backgroundColor('#fff0f0f0')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          RichEditor({ controller: this.ctrl })
            .width('100%')
            .padding({ top: 15 })
            .defaultFocus(true)
            .customKeyboard(this.isEmojiKeyboard ? this.emojiKeyBoard() : undefined)
            .aboutToIMEInput((value) => {
              this.ctrl.addTextSpan(value.insertValue, {
                offset: value.insertOffset,
                style: {
                  lineHeight: 30,
                  fontSize: 16
                },
                gesture: {
                  onClick: () => {
                    this.isEmojiKeyboard = false;
                  }
                }
              })
              return false;
            })
          Row() {
            Checkbox()
              .width(10)
              .height(10)
              .margin({ left: 10 })
            Text($r('app.string.input_forward'))
              .fontSize(10)
            Image(this.isEmojiKeyboard ? $r('app.media.input_emoji') : $r('app.media.input_kb'))
              .width(30)
              .height(30)
              .margin({ left: 10 })
              .onClick(() => {
                this.isEmojiKeyboard = !this.isEmojiKeyboard;
              })
            Image($r('app.media.input_at'))
              .width(30)
              .height(30)
              .margin({ left: 10 })
            Image($r('app.media.input_img'))
              .width(30)
              .height(30)
              .margin({ left: 10 })
            Blank().layoutWeight(1)
            Text($r('app.string.input_submit'))
              .fontSize(14)
              .fontColor(Color.White)
              .padding({ left: 10, top: 5, right: 10, bottom: 5 })
              .margin({ top: 10, bottom: 10, right: 10 })
              .backgroundColor($r('app.color.bili_pink'))
              .borderRadius(20)
              .clip(true)
          }
          Blank().height(this.keyBoardHeight)
        }.backgroundColor(Color.White)
        .borderRadius({ topLeft: 8, topRight: 8 })
        .clip(true)
        .onClick(() => {})
      }.width('100%')
      .height('100%')
      .onClick(() => {
        this.navStack.pop();
      })
    }.mode(NavDestinationMode.DIALOG)
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .hideTitleBar(true)
    .onBackPressed(() => {
      return false;
    })
  }
}