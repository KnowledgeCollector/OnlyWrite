export class MdMenuBean {
  menuId: number = 0
  name: string = ""
  icon: Resource = $r('app.media.startIcon')

  constructor(menuId: number, name: string, icon: Resource) {
    this.menuId = menuId
    this.name = name
    this.icon = icon
  }
}