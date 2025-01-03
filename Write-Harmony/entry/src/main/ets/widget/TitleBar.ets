import { router } from "@kit.ArkUI"

@Component
export struct TitleBar {
  @Prop title: string | Resource
  @Prop rightImgMenu1: Resource
  @Prop rightImgMenu2: Resource
  onRightImgMenu1Click?: () => void;
  onRightImgMenu2Click?: () => void;

  build() {
    //标题栏
    RelativeContainer() {
      Image($r('app.media.back'))
        .width(20)
        .height(20)
        .onClick((event) => {
          router.back()
        })
        .id('back')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })

      Text(this.title)
        .fontSize(18)
        .fontWeight(400)
        .id('title')
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      //右侧第一个图片菜单
      if (this.rightImgMenu1 != null) {
        Image(this.rightImgMenu1)
          .width(20)
          .height(20)
          .id('right_img_menu1')
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .onClick(() => {
            if (this.onRightImgMenu1Click) {
              this.onRightImgMenu1Click()
            }
          })
        //右侧第二个图片菜单
        if (this.rightImgMenu2 != null) {
          Image(this.rightImgMenu2)
            .width(20)
            .height(20)
            .margin({ right: 15 })
            .id('right_img_menu2')
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              right: { anchor: 'right_img_menu1', align: HorizontalAlign.Start }
            })
            .onClick(() => {
              if (this.onRightImgMenu2Click) {
                this.onRightImgMenu2Click()
              }
            })
        }
      }

    }.height(40).padding({ left: 15, right: 20 })
  }
}
