@Component
export struct TagItem {
  @Prop tag: string
  bgColor: Resource = $r('sys.color.ohos_id_color_sub_background')
  fontSize: number = 10

  build() {
    Text(this.tag)
      .fontSize(this.fontSize)
      .backgroundColor(this.bgColor)
      .borderRadius(10)
      .padding({
        left: 4,
        right: 4,
        top: 1,
        bottom: 1
      })
      .margin({ right: 4 })
  }
}