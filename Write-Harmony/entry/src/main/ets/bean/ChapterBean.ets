export class ChapterBean {
  id: number = 0
  chapterName: string = ""
  orderNum: number = 0
  bookId: number = 0

  constructor(id: number, chapterName: string, orderNum: number, bookId: number) {
    this.id = id
    this.bookId = bookId
    this.chapterName = chapterName
    this.orderNum = orderNum
  }
}