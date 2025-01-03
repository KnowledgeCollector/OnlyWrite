import { router } from '@kit.ArkUI'
import { BookBean } from '../../bean/BookBean'
import { ChapterBean } from '../../bean/ChapterBean'
import { BookDbManager } from '../../model/db/BookDbManager'
import { ChapterDbManager } from '../../model/db/ChapterDbManager'
import { DialogUtil, PreferencesUtil, ToastUtil } from '@pura/harmony-utils'
import { InputDialog } from '../dialog/InputDialog'
import { NoteDbManager } from '../../model/db/NoteDbManager'
import { TitleBar } from '../../widget/TitleBar'
import { PageBean } from '../../bean/PageBean'
import { Constants } from '../../utils/Constants'

@Entry
@Component
struct BookChapterPage {
  pageBean: PageBean = router.getParams() as PageBean
  @State bookId: number = 1
  @State books: Array<BookBean> = []
  @State chapters: Array<ChapterBean> = []
  //当前列表
  @State list: Array<BookBean | ChapterBean> = []
  //横向目录
  @State folders: Array<BookBean> = []
  //显示编辑菜单的条目集合
  @State editList: Map<string, string> = new Map()
  //当前编辑
  @State editNode: BookBean | ChapterBean | null = null
  //当前编辑-name
  @State editText: string = ""

  async aboutToAppear() {
    let appName = await getContext(this).resourceManager.getStringByName('root');
    let rootBook = new BookBean(0, appName, 0, 0)
    this.editList.set(rootBook.id + rootBook.bookName, "")
    await this.initData()
    this.getList(rootBook)
  }

  async initData() {
    this.bookId = PreferencesUtil.getNumberSync(Constants.Key_BookId, 1)
    this.books = await BookDbManager.getInstance().getAllBooks()
    this.chapters = await ChapterDbManager.getInstance().getAllChapters()
  }

  getList(bean: BookBean) {
    this.list = []
    if (this.folders.indexOf(bean) >= 0) {
      let index = this.folders.indexOf(bean)
      while (this.folders.length > index + 1) {
        this.folders.pop()
      }
    } else {
      this.folders.push(bean)
    }
    this.books.forEach((item) => {
      if (item.parentBookId == bean.id) {
        this.list.push(item)
      }
    })
    this.chapters.forEach((item) => {
      if (item.bookId == bean.id) {
        this.list.push(item)
      }
    })
  }

  build() {
    Column() {
      //顶部栏
      TitleBar({
        title: $r('app.string.book_manager'), rightImgMenu1: $r("app.media.add_black"), onRightImgMenu1Click: () => {
          if (this.folders.length == 1) {
            this.addBook()
          } else {
            this.addChapter()
          }
        }
      })
      //横向目录
      List() {
        ForEach(this.folders, (item: BookBean) => {
          ListItem() {
            Row() {
              if (this.folders.indexOf(item) > 0) {
                Image($r('app.media.menu_arr')).width(10).height(10).margin({ left: 5, right: 5 })
              }
              Text(item.bookName).fontSize(16)
            }
          }.height('100%').onClick((event) => {
            this.getList(item)
          })
        })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 20 })
      .listDirection(Axis.Horizontal)

      //分类列表
      Grid() {
        ForEach(this.list, (item: BookBean | ChapterBean) => {
          GridItem() {
            if (item instanceof BookBean) {
              Row() {
                Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).select(item.id == this.bookId).onChange((selct) => {
                  router.back({
                    url: this.pageBean.fromPageUrl,
                    params: {
                      book: item
                    }
                  })
                })
                Row() {
                  Image($r('app.media.book')).width(18).height(18)
                  Text(item.bookName)
                    .fontSize(16)
                    .fontWeight(400)
                    .margin({ left: 10 })
                  Blank()
                  if (this.editList.has(item.id + item.bookName)) {
                    Row() {
                      Image($r('app.media.edit_black')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                        this.editBook(item)
                      })
                      Image($r('app.media.top')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                        this.upBook(item)
                      })
                      Image($r('app.media.down')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                        this.downBook(item)
                      })
                      Image($r('app.media.delete')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                        this.deleteBook(item)
                      })
                    }
                  }
                  Image($r('app.media.more')).width(20).height(20).onClick((event) => {
                    if (this.editList.has(item.id + item.bookName)) {
                      this.editList.delete(item.id + item.bookName)
                    } else {
                      this.editList.set(item.id + item.bookName, "")
                    }
                  })
                }
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Start)
                .layoutWeight(1)
                .borderRadius(10)
                .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
                .padding({
                  left: 20,
                  right: 10,
                  top: 10,
                  bottom: 10
                })
                .margin({ left: 10 })
                .onClick((event) => {
                  this.getList(item)
                })
              }
            } else {
              Row() {
                Image($r('app.media.chapter')).width(18).height(18)
                Text(item.chapterName)
                  .fontSize(16)
                  .fontWeight(400)
                  .margin({ left: 10 })
                Blank()
                if (this.editList.has(item.id + item.chapterName)) {
                  Row() {
                    Image($r('app.media.edit_black')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                      this.editType(item)
                    })
                    Image($r('app.media.top')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                      this.upType(item)
                    })
                    Image($r('app.media.down')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                      this.downType(item)
                    })
                    Image($r('app.media.delete')).width(20).height(20).margin({ right: 10 }).onClick(() => {
                      this.deleteType(item)
                    })
                  }
                }
                Image($r('app.media.more')).width(18).height(18).onClick((event) => {
                  if (this.editList.has(item.id + item.chapterName)) {
                    this.editList.delete(item.id + item.chapterName)
                  } else {
                    this.editList.set(item.id + item.chapterName, "")
                  }
                })
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .borderRadius(10)
              .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
              .padding({
                left: 20,
                right: 10,
                top: 10,
                bottom: 10
              })
              .onClick((event) => {
                this.editType(item)
              })
            }
          }
        })
      }
      .cachedCount(10)
      .columnsGap(10)
      .rowsGap(10)
      .columnsTemplate('1fr')
      .padding({ left: 15, right: 15 })
      .scrollBar(BarState.Off)
    }
  }

  //新增
  addBook() {
    let parentNode = this.folders[this.folders.length-1]
    this.editText = ""
    this.editNode = new BookBean(Math.round(Date.now() / 1000), "", this.books.length + 1, parentNode.id)
    this.editDialogController?.open()
  }

  //新增
  addChapter() {
    let parentNode = this.folders[this.folders.length-1]
    this.editText = ""
    this.editNode = new ChapterBean(Math.round(Date.now() / 1000), "", this.chapters.length + 1, parentNode.id)
    this.editDialogController?.open()
  }

  //收藏夹
  editBook(book: BookBean) {
    this.editNode = book
    this.editText = book.bookName
    this.editDialogController?.open();
  }

  async upBook(book: BookBean) {
    let from = this.list.findIndex((bean) => {
      return ((bean instanceof BookBean) && bean.id == book.id)
    })
    let to = (from - 1 > -1) ? from - 1 : 0
    await this.changePosition(from, to, true)
  }

  async downBook(book: BookBean) {
    let from = this.list.findIndex((bean) => {
      return ((bean instanceof BookBean) && bean.id == book.id)
    })
    let to = (from + 1 < this.list.length) ? from + 1 : this.list.length - 1
    if (this.list[to] instanceof ChapterBean) {
      return
    }
    await this.changePosition(from, to, true)
  }

  deleteBook(book: BookBean) {
    if (book.id == this.bookId) {
      ToastUtil.showToast($r('app.string.cannot_delete_book'))
      return
    }
    DialogUtil.showPrimaryDialog({
      title: $r('app.string.hint'),
      message: $r('app.string.delete_book'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: async () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: async () => {
          for (let i = 0; i < this.list.length; i++) {
            if ((this.list[i] instanceof ChapterBean) && this.list[i].id == book.id) {
              await NoteDbManager.getInstance().deleteNoteByChapter((this.list[i] as ChapterBean).id)
              await ChapterDbManager.getInstance().deleteChapter((this.list[i] as ChapterBean).id)
            }
          }
          await BookDbManager.getInstance().deleteBook(book.id)
          this.refresh()
        }
      }
    })
  }

  //分类
  editType(type: ChapterBean) {
    this.editNode = type
    this.editText = type.chapterName
    this.editDialogController?.open();
  }

  async upType(type: ChapterBean) {
    let from = this.list.findIndex((bean) => {
      return ((bean instanceof ChapterBean) && bean.id == type.id)
    })
    let to = (from - 1 > -1) ? from - 1 : 0
    if (this.list[to] instanceof BookBean) {
      return
    }
    await this.changePosition(from, to, false)
  }

  async downType(type: ChapterBean) {
    let from = this.list.findIndex((bean) => {
      return ((bean instanceof ChapterBean) && bean.id == type.id)
    })
    let to = (from + 1 < this.list.length) ? from + 1 : this.list.length - 1
    await this.changePosition(from, to, false)
  }

  deleteType(type: ChapterBean) {
    DialogUtil.showPrimaryDialog({
      title: $r('app.string.hint'),
      message: $r('app.string.delete_chapter'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: async () => {
          await NoteDbManager.getInstance().deleteNoteByChapter(type.id)
          await ChapterDbManager.getInstance().deleteChapter(type.id)
          this.refresh()
        }
      }
    })
  }

  //新增编辑弹窗
  editDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    builder: InputDialog({
      content: this.editText,
      publish: async (content) => {
        if (this.editNode instanceof BookBean) {
          if (this.editList.has(this.editNode.id + this.editNode.bookName)) {
            //编辑
            this.editNode.bookName = content
            await BookDbManager.getInstance().updateBook(this.editNode)
            this.refresh()
          } else {
            //新增
            this.editNode.bookName = content
            await BookDbManager.getInstance().insertBook(this.editNode)
            this.refresh()
          }
        } else if (this.editNode instanceof ChapterBean) {
          if (this.editList.has(this.editNode.id + this.editNode.chapterName)) {
            //编辑
            this.editNode.chapterName = content
            await ChapterDbManager.getInstance().updateChapter(this.editNode)
            this.refresh()
          } else {
            //新增
            this.editNode.chapterName = content
            await ChapterDbManager.getInstance().insertChapter(this.editNode)
            this.refresh()
          }
        }
      }
    })
  });

  //刷新
  async refresh() {
    await this.initData()
    this.getList(this.folders[this.folders.length-1])
  }

  //上下移动
  async changePosition(from: number, to: number, isBook: boolean) {
    let removed = this.list.splice(from, 1);
    this.list.splice(to, 0, ...removed);
    for (let i = 0; i < this.list.length; i++) {
      if (isBook) {
        if (this.list[i] instanceof BookBean) {
          this.list[i].orderNum = i
          await BookDbManager.getInstance().updateBook(this.list[i] as BookBean)
        }
      } else {
        if (this.list[i] instanceof ChapterBean) {
          this.list[i].orderNum = i
          await ChapterDbManager.getInstance().updateChapter(this.list[i] as ChapterBean)
        }
      }
    }
    this.refresh()
  }
}