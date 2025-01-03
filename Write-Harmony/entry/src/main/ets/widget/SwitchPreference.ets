@Component
export struct SwitchPreference {
  @Prop title: string | Resource
  @Prop content: string | Resource
  @State isOpen: boolean = false

  build() {
    Row() {
      Column() {
        Text(this.title).fontSize(16)
        Text(this.content)
          .fontSize(13)
          .fontColor(Color.Grey)
          .margin({ top: 5 })
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 10 })

      Stack() {
        Toggle({ type: ToggleType.Switch, isOn: this.isOpen }).height(30).width(50)
        Text().height(30).width(50)
      }
    }.margin({ top: 20 }).alignItems(VerticalAlign.Center)
  }
}