export class PageBean {
  fromPageUrl: string = ""
  pageTitle: string | Resource = ""
  params: object | string | null

  constructor(pageUrl: string = "", pageTitle: string | Resource = "", params: object | string | null = null) {
    this.fromPageUrl = pageUrl
    this.params = params
    this.pageTitle = pageTitle
  }
}