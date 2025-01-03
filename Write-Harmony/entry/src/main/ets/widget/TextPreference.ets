
@Component
export struct TextPreference {
  @Prop title: string | Resource
  @Prop content: string
  constantKey: string = ''

  build() {
    Column() {
      Text(this.title).fontSize(16)
      Text(this.content)
        .fontSize(13)
        .fontColor(Color.Grey)
        .margin({ top: 5 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 20 })
  }
}