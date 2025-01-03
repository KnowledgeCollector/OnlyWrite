import { ResUtil } from "@pura/harmony-utils";
import { RadioMenuBean } from "../../bean/RadioMenuBean";

@CustomDialog
export struct RadioDialog {
  titlt: string | Resource = ""
  menus: Array<RadioMenuBean> = []
  itemClick: (index: number) => void = (index: number): void => {
  }
  controller?: CustomDialogController;

  build() {
    Column() {
      Text(this.titlt).fontSize(20).margin({ left: 5, top: 5, bottom: 15 })
      Grid() {
        ForEach(this.menus, (item: RadioMenuBean, index: number) => {
          GridItem() {
            Row() {
              Radio({ value: ResUtil.getStringSync(item.name), group: 'colorModeRadioGroup' })
                .checked(item.check)
                .onChange((isChecked: boolean) => {
                  this.itemClick(index)
                  this.controller?.close()
                })
              Text(item.name).fontSize(16).layoutWeight(1).margin({ left: 10 })
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
          }
          .onClick((event) => {
            this.itemClick(index);
            this.controller?.close();
          })
        })
      }
      .cachedCount(10)
      .columnsGap(10)
      .rowsGap(16)
      .columnsTemplate('1fr')
      .scrollBar(BarState.Off)
      .height(this.menus.length * 35 + 50)
    }
    .padding(15)
    .margin(25)
    .borderRadius(15)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}