import { PageBean } from "../../bean/PageBean"
import { CommUtils } from "../../utils/CommUtils"

@CustomDialog
export struct AppTipDialog {
  controller?: CustomDialogController
  publish: () => void = (): void => {
  }
  cancel: () => void = (): void => {
  }

  build() {
    Column() {
      Text($r('app.string.weclome')).textAlign(TextAlign.Start).width('100%').fontSize(20)
      Text() {
        Span('在使用本应用前请您务必认真阅读本软件的')
        Span('《隐私政策》').fontColor(Color.Blue).onClick(() => {
          this.controller?.close()
          CommUtils.openPage("pages/other/WebPage", new PageBean("0", $r('app.string.privacy')))
        })
        Span('，在此特别声明：\n\n本应用收集信息和使用权限均为在您需要该项服务时向您获取授权，我们不会向任何第三方透漏您的隐私信息。\n\n点击确定即表示您已阅读并同意该条款。')
      }.fontSize(14).margin({ top: 20, bottom: 10 })

      Row() {
        Text($r('app.string.cancel'))
          .width(60)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.cancel();
            this.controller?.close()
          })
        Text($r('app.string.confirm'))
          .width(60)
          .height(40)
          .onClick(() => {
            this.publish();
            this.controller?.close()
          })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(20)
    .margin(20)
    .borderRadius(20)
    .backgroundColor(Color.White)
    .offset({ y: 20 })
  }
}