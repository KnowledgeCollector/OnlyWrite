import { DialogUtil, EmitterUtil, FileUtil, PasteboardUtil, PreferencesUtil, ToastUtil } from '@pura/harmony-utils';
import { BookBean } from '../../bean/BookBean';
import { ChapterBean } from '../../bean/ChapterBean';
import { NoteBean } from '../../bean/NoteBean';
import { PageBean } from '../../bean/PageBean';
import { RadioMenuBean } from '../../bean/RadioMenuBean';
import { BookDbManager } from '../../model/db/BookDbManager';
import { ChapterDbManager } from '../../model/db/ChapterDbManager';
import { NoteDbManager } from '../../model/db/NoteDbManager';
import { AppHelper } from '../../utils/AppHelper';
import { CommUtils } from '../../utils/CommUtils';
import { Constants } from '../../utils/Constants';
import { NoteItem } from '../../widget/NoteItem';
import { MenusDialog } from '../dialog/MenusDialog';
import { RadioDialog } from '../dialog/RadioDialog';
import { router } from '@kit.ArkUI';
import { InputDialog } from '../dialog/InputDialog';


@Entry
@Component
struct LeftPage {
  pageBean: PageBean = router.getParams() as PageBean
  //-----------笔记相关-----------------
  @State chapters: Array<ChapterBean> = []
  @State pagesMap: Record<string, Array<NoteBean>> = {}
  //正在编辑的
  @State bookName: string = ""
  @State noteSize: number = 0
  @State bookId: number = 1
  @State chapterId: number = 1
  @State noteId: number = 1
  //每次滑动到当前编辑文章
  listScroller: ListScroller = new ListScroller()
  @State noteGroupIndex: number = 0
  @State noteIndexInGroup: number = 0
  //选中的
  @State currentNote: NoteBean | null = null
  //-----------菜单相关-----------------
  @State sortType: number = 0

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 250 }).slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.Pop, duration: 250 }).slide(SlideEffect.Left)
  }

  aboutToAppear() {
    this.init()
  }

  init() {
    this.bookId = PreferencesUtil.getNumberSync(Constants.Key_BookId, 1)
    this.chapterId = PreferencesUtil.getNumberSync(Constants.Key_ChapterId, 1)
    this.noteId = PreferencesUtil.getNumberSync(Constants.Key_NoteId, 1)
    this.sortType = PreferencesUtil.getNumberSync(Constants.Menu_SortType, 0)
    AppHelper.sortType = this.sortType
    this.getData()
  }

  //切换书籍
  changeBook(book: BookBean) {
    this.bookId = book.id
    PreferencesUtil.putSync(Constants.Key_BookId, book.id)
    this.init()
  }

  getData() {
    BookDbManager.getInstance().getBookById(this.bookId).then((books: Array<BookBean>) => {
      if (books.length > 0) {
        this.bookName = books[0].bookName
        this.getChapters()
      }
    })
  }

  getChapters() {
    ChapterDbManager.getInstance().getChaptersByBookId(this.bookId).then(async (types: Array<ChapterBean>) => {
      this.chapters = types
      this.pagesMap = {}
      this.noteSize = 0
      for (let i = 0; i < this.chapters.length; i++) {
        let notes = await this.getNotes(this.chapters[i].id)
        this.pagesMap[this.chapters[i].id.toString()] = notes
        //统计当前书籍总文章数
        this.noteSize += notes.length
        // //定位当前编辑文章位置
        if (this.chapters[i].id == this.chapterId) {
          this.noteGroupIndex = i
          for (let j = 0; j < notes.length; j++) {
            if (this.noteId == notes[j].pageId) {
              this.noteIndexInGroup = j
            }
          }
        }
      }
      setTimeout(() => {
        try {
          this.listScroller.scrollToItemInGroup(this.noteGroupIndex, this.noteIndexInGroup, true)
        } catch (e) {
        }
      }, 500)
    })
  }

  getNotes(chapterId: number): Promise<Array<NoteBean>> {
    return NoteDbManager.getInstance().getNoteByChapterId(chapterId)
  }

  onPageShow(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, PageBean | BookBean>; // 获取传递过来的参数对象
    if (params) {
      //切换书籍
      if (params.book) {
        let book: BookBean = params.book as BookBean
        this.changeBook(book)
      }
    }
  }

  build() {
    Column() {
      //顶部栏
      Row() {
        Text(this.bookName)
          .fontSize(18)
          .fontWeight(400)
          .onClick((event) => {
            //切换书籍
            CommUtils.openPage("pages/other/BookChapterPage", new PageBean("pages/edit/LeftPage"))
          })
        Text("(" + this.noteSize.toString() + ")").fontSize(12).fontWeight(200).margin({ left: 5 })
        Image($r('app.media.arr_down')).width(10).height(10).margin({ left: 5 })
        Blank()
        Image($r('app.media.sort')).width(20).height(20).margin({ left: 15 }).onClick((event) => {
          this.sortTypeDialogController?.open()
        })
        Image($r("app.media.more")).width(20).height(20).margin({ left: 15 }).onClick((event) => {
          this.moreDialogController?.open()
        })
      }.width('100%')
      .height(40)
      .padding({ left: 15, right: 15 })
      .alignItems(VerticalAlign.Center)

      //tab列表页面
      List({ scroller: this.listScroller }) {
        ForEach(this.chapters, (item: ChapterBean) => {
          ListItemGroup({ header: this.chapterHead(item) }) {
            ForEach(this.pagesMap[item.id.toString()], (note: NoteBean) => {
              ListItem() {
                NoteItem({
                  selctNoteId: this.noteId,
                  noteBean: note,
                  itemClick: () => {
                    //选择文章
                    router.back({
                      url: this.pageBean.fromPageUrl,
                      params: {
                        note: note
                      }
                    })
                  },
                  itemLongClick: () => {
                    //长按文章
                    this.currentNote = note
                    this.noteMenuDialogController?.open()
                  }
                })
              }
            }, (note: NoteBean) => JSON.stringify(note))
          }
          .divider({ strokeWidth: 1, color: $r('sys.color.ohos_id_color_sub_background') })
          .height(300)
        }, (chapter: ChapterBean) => JSON.stringify(chapter))
      }
      .width('100%')
      .height('100%')
      .sticky(StickyStyle.Header)
      .scrollBar(BarState.Off)
      .padding({ bottom: 20 })

    }.width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  chapterHead(chapter: ChapterBean) {
    Column() {
      Blank()
        .width('100%')
        .height(0.5)
        .color($r('app.color.pull_refresh_dividerColor'))
        .width('100%')
        .layoutWeight(1)

      Row() {
        Image($r('app.media.arr_down')).width(15).height(15).margin({ left: 15, right: 10 })
        Text(chapter.chapterName).fontSize(16).fontWeight(500)
        Blank()
        Image($r('app.media.add_page')).width(15).height(15).margin({ right: 15 }).onClick((event) => {
          //新增文章
          let note =
            new NoteBean(Math.round(Date.now() / 1000), chapter.id, "", "", Date.now(), Date.now(), false, 0, 0)
          NoteDbManager.getInstance().insertNote(note).then((ok) => {
            router.back({
              url: this.pageBean.fromPageUrl,
              params: {
                note: note
              }
            })
          })
        })
      }.backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .width('100%').height(39)

      Blank()
        .width('100%')
        .height(0.5)
        .color($r('app.color.pull_refresh_dividerColor'))
        .width('100%')
        .layoutWeight(1)
    }.alignItems(HorizontalAlign.Start)
    .height(40).width('100%')
  }

  //排序菜单弹窗
  sortTypeDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: RadioDialog({
      titlt: $r('app.string.sorttype'),
      menus: [
        new RadioMenuBean($r('app.string.create_time_asc'), AppHelper.sortType == 0),
        new RadioMenuBean($r('app.string.create_time_desc'), AppHelper.sortType == 1),
        new RadioMenuBean($r('app.string.edit_time_asc'), AppHelper.sortType == 2),
        new RadioMenuBean($r('app.string.edit_time_desc'), AppHelper.sortType == 3),
        new RadioMenuBean($r('app.string.file_name_asc'), AppHelper.sortType == 4),
        new RadioMenuBean($r('app.string.file_name_desc'), AppHelper.sortType == 5)
      ],
      itemClick: (index) => {
        AppHelper.sortType = index
        PreferencesUtil.putSync(Constants.Menu_SortType, index)
        this.getData()
      }
    })
  });
  //更多菜单
  moreDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: MenusDialog({
      titlt: this.bookName,
      menus: [
        $r('app.string.add_chapter'),
      // $r('app.string.outpu_book'),
      ],
      itemClick: (index) => {
        if (index == 0) {
          this.editDialogController?.open()
        } else if (index == 1) {
        }
      }
    })
  });
  //新增编辑弹窗
  editDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    builder: InputDialog({
      content: "",
      publish: async (content) => {
        let bean = new ChapterBean(Math.round(Date.now() / 1000), content, this.chapters.length + 1, this.bookId)
        await ChapterDbManager.getInstance().insertChapter(bean)
        this.getData()
      }
    })
  });
  //长按菜单
  noteMenuDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: MenusDialog({
      titlt: this.currentNote?.title,
      menus: [
        $r('app.string.copy_page'),
        $r('app.string.delete_page'),
      // $r('app.string.save_page')
      ],
      itemClick: (index) => {
        if (index == 0) {
          //复制
          PasteboardUtil.setDataText(this.currentNote?.title + "\n" + this.currentNote?.content)
          ToastUtil.showToast($r('app.string.copy_ok'))
        } else if (index == 1) {
          //删除
          DialogUtil.showPrimaryDialog({
            title: $r('app.string.hint'),
            message: $r('app.string.delete_page'),
            primaryButton: {
              value: $r('app.string.cancel'),
              action: async () => {
              }
            },
            secondaryButton: {
              value: $r('app.string.confirm'),
              action: async () => {
                if (this.currentNote) {
                  NoteDbManager.getInstance().deleteNote(this.currentNote.pageId)
                  this.getData()
                  if (this.noteId == this.currentNote.pageId) {
                    //删除当前选中文章时刷新首页
                    EmitterUtil.post<number>(Constants.Message_Delete_Current_Edit, 0)
                  }
                }
              }
            }
          })
        } else if (index == 2) {
          //另存为
        }
      }
    })
  });
}

