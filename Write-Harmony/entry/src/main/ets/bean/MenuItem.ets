export class MenuItem {
  name: Resource = $r('app.string.root');
  icon: Resource = $r('app.media.ic_tabs_icon');

  constructor(name: Resource, icon: Resource) {
    this.name = name
    this.icon = icon
  }
}