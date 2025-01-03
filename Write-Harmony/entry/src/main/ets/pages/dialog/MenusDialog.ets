@CustomDialog
export struct MenusDialog {
  titlt: string | Resource = ""
  menus: Array<string | Resource> = []
  itemClick: (index: number) => void = (index: number): void => {
  }
  controller?: CustomDialogController;

  build() {
    Column() {
      Text(this.titlt).fontSize(20).margin({ left: 5, top: 10, bottom: 20 })
      Grid() {
        ForEach(this.menus, (item: string | Resource, index: number) => {
          GridItem() {
            Text(item)
              .fontSize(16)
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 10 })
              .textAlign(TextAlign.Start)
          }
          .onClick((event) => {
            this.itemClick(index);
            this.controller?.close();
          })
        })
      }
      .cachedCount(10)
      .columnsGap(10)
      .rowsGap(20)
      .columnsTemplate('1fr')
      .scrollBar(BarState.Off)
      .height(this.menus.length * 28 + 30)
    }
    .padding(15)
    .margin(25)
    .borderRadius(15)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}