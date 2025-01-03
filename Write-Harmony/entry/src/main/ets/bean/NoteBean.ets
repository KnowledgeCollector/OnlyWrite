export class NoteBean {
  pageId: number = 0
  chapterId: number = 0
  title: string = ""
  content: string = ""
  createTime: number = 0
  editTime: number = 0
  isdelete: boolean = false
  deleteTime: number = 0
  orderNum: number = 0

  constructor(pageId: number, chapterId: number, title: string, content: string,
    createTime: number, editTime: number, isPreview: boolean, deleteTime: number,
    orderNum: number) {
    this.pageId = pageId
    this.chapterId = chapterId
    this.title = title
    this.content = content
    this.createTime = createTime
    this.editTime = editTime
    this.isdelete = isPreview
    this.deleteTime = deleteTime
    this.orderNum = orderNum
  }
}
