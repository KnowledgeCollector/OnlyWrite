@CustomDialog
export struct InputDialog {
  content: string = ""
  inputType: InputType = InputType.Normal
  controller?: CustomDialogController
  rightBtn: Resource | string = $r('app.string.save')
  publish: (txt: string) => void = (txt: string): void => {
  }
  leftBtn: Resource | string | null = null
  cancel: (txt: string) => void = (txt: string): void => {
  }

  aboutToAppear(): void {
    if (!this.content) {
      this.content = ""
    }
  }

  build() {
    Column() {
      Row() {
        if (this.leftBtn) {
          Text(this.leftBtn)
            .width(60)
            .height(40)
            .borderColor(Color.Grey)
            .borderWidth(1)
            .borderRadius(90)
            .textAlign(TextAlign.Center)
            .margin({ right: 10 })
            .onClick(() => {
              this.cancel(this.content);
              this.controller?.close()
            })
        }
        TextInput({ text: this.content })
          .height(40)
          .padding(10)
          .margin({ right: 10 })
          .type(this.inputType)
          .onChange((textInComment: string) => {
            this.content = textInComment;
          })
          .defaultFocus(true)
          .layoutWeight(1)

        Button($r('app.string.save'))
          .width(60)
          .height(40)
          .borderRadius(10)
          .onClick(() => {
            this.publish(this.content);
            this.controller?.close()
          })
      }
      .padding(15)
      .height(70)
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}