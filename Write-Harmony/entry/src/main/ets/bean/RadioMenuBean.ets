export class RadioMenuBean {
  name: Resource = $r('app.string.root');
  check: boolean = false;

  constructor(name: Resource, check: boolean) {
    this.name = name
    this.check = check
  }
}