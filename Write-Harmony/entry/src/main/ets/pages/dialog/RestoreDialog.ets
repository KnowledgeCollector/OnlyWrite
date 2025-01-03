import { AliyunFile } from "../../bean/AliyunFile";
import { BaiduListlFile } from "../../bean/BaiduListFile";

@CustomDialog
export struct RestoreDialog {
  dataType: number = 0
  files: Array<AliyunFile | BaiduListlFile> = []
  publish: (index: number) => void = (index: number): void => {

  }
  controller?: CustomDialogController;

  build() {
    Column() {
      Grid() {
        ForEach(this.files, (item: AliyunFile | BaiduListlFile, index: number) => {
          GridItem() {
            Row() {
              Text(this.dataType == 1 ? (item as AliyunFile).name : (item as BaiduListlFile).server_filename)
                .fontSize(14)
                .layoutWeight(1)
              Radio({
                value: this.dataType == 1 ? (item as AliyunFile).name :
                (item as BaiduListlFile).server_filename,
                group: 'colorModeRadioGroup'
              })
                .onChange((isChecked: boolean) => {
                  this.publish(index)
                  this.controller?.close()
                })
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
          }
          .padding(10)
          .borderRadius(10)
          .borderWidth(1)
          .borderColor(Color.Grey)
          .backgroundColor($r('sys.color.white'))
          .onClick((event) => {
            this.publish(index);
            this.controller?.close();
          })
        })
      }
      .cachedCount(10)
      .columnsGap(10)
      .rowsGap(10)
      .columnsTemplate('1fr')
      .scrollBar(BarState.Off)
      .height(Math.max(this.files.length * 60 + 30, 240))

    }
    .padding(15)
    .borderRadius(10)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}