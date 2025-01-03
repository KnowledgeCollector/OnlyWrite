@CustomDialog
export struct MdLinkDialog {
  controller?: CustomDialogController;
  publish: (title: string, url: string) => void = (title: string, url: string): void => {
  }
  @State title: string = ""
  @State url: string = ""

  build() {
    Column() {
      Row() {
        Text($r('app.string.cancel'))
          .borderRadius(10)
          .onClick(() => {
            this.publish(this.title, this.url);
            this.controller?.close();
          })
        Blank().layoutWeight(1)
        Text($r('app.string.confirm'))
          .borderRadius(10)
          .onClick(() => {
            this.publish(this.title, this.url);
            this.controller?.close();
          })
      }
      .alignItems(VerticalAlign.Center)

      Row() {
        Text($r('app.string.title')).fontSize(16)
        TextInput()
          .height(40)
          .padding({ left: 20, right: 20 })
          .margin({ left: 10, right: 10 })
          .onChange((textInComment: string) => {
            this.title = textInComment
          })
          .defaultFocus(true)
          .layoutWeight(1)
      }
      .height(40)
      .margin({ top: 10 })

      Row() {
        Text($r('app.string.link')).fontSize(16)
        TextInput()
          .height(40)
          .padding({ left: 20, right: 20 })
          .margin({ left: 10, right: 10 })
          .onChange((textInComment: string) => {
            this.url = textInComment
          })
          .defaultFocus(true)
          .layoutWeight(1)
      }
      .margin({ top: 10 })
      .height(40)
    }
    .padding(15)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}