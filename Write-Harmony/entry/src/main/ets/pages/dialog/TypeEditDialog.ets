
@CustomDialog
export struct TypeEditDialog {
  txt: string=""
  colorId:string="#ffffff"
  @State currentColor: string = ""
  controller?: CustomDialogController;
  publish: (txt: string,colorId:string) => void = (txt: string,colorId:string): void => {

  }
  notes: Array<string> = [
    "#000000", "#2a176f", "#0076bc", "#8A2BE1", "#0094dd", "#00AAEF",
    "#8F8FBD", "#00BFC9", "#32CD99", "#70DB93", "#fff500", "#FFBE00",
    "#FFD700", "#add206", "#FF7500", "#46CC47", "#FB2A2D", "#007947"]

  build() {
    Column() {
      //颜色选择
      Grid() {
        ForEach(this.notes, (item: string) => {
          GridItem() {
            Text()
              .height(25)
              .width(25)
              .borderRadius(90)
              .borderWidth(13)
              .borderColor(item)
          }
          .backgroundColor($r('sys.color.white'))
          .onClick((event) => {
            this.currentColor = item
            this.colorId = item
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .scrollBar(BarState.Off)
      .height(100)

      //输入框
      Row() {
        TextInput({ text: this.txt })
          .fontColor(this.currentColor)
          .height(40)
          .padding(10)
          .margin({ right: 10 })
          .onChange((textInComment: string) => {
            this.txt = textInComment;
          })
          .defaultFocus(true)
          .layoutWeight(1)

        Button($r('app.string.save'))
          .width(60)
          .height(40)
          .borderRadius(10)
          .onClick(() => {
            this.publish(this.txt,this.colorId);
            this.controller?.close();
          })
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
      }
      .padding(15)
      .height(70)
    }
    .height(200)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}