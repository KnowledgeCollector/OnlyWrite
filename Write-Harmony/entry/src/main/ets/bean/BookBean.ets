export class BookBean {
  id: number = 0
  bookName: string = ""
  orderNum: number = 0
  parentBookId: number = 0

  constructor(id: number, bookName: string, orderNum: number, parentBookId: number) {
    this.id = id
    this.parentBookId = parentBookId
    this.orderNum = orderNum
    this.bookName = bookName
  }
}