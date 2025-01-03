@CustomDialog
export struct MdGridDialog {
  controller?: CustomDialogController;
  publish: (trow: number, column: number) => void = (row: number, column: number): void => {
  }
  @State row: number = 2
  @State column: number = 2

  build() {
    Column() {
      Row() {
        Text($r('app.string.cancel'))
          .borderRadius(10)
          .fontSize(16)
          .onClick(() => {
            this.publish(0, 0);
            this.controller?.close();
          })
        Blank().layoutWeight(1)
        Text($r('app.string.confirm'))
          .fontSize(16)
          .borderRadius(10)
          .onClick(() => {
            this.publish(this.row, this.column);
            this.controller?.close();
          })
      }
      .alignItems(VerticalAlign.Center)

      Row() {
        Text($r('app.string.row')).fontSize(16)
        TextInput()
          .height(40)
          .padding({ left: 20, right: 20 })
          .type(InputType.Number)
          .margin({ left: 10, right: 10 })
          .onChange((textInComment: string) => {
            this.row = Number.parseInt(textInComment);
          })
          .defaultFocus(true)
          .layoutWeight(1)
        Text($r('app.string.column')).fontSize(16)
        TextInput()
          .height(40)
          .padding({ left: 20, right: 20 })
          .type(InputType.Number)
          .margin({ left: 10, right: 10 })
          .onChange((textInComment: string) => {
            this.column = Number.parseInt(textInComment);
            this.controller?.close()
          })
          .defaultFocus(true)
          .layoutWeight(1)
      }
      .margin({ top: 5 })
      .height(40)
    }
    .padding(15)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}