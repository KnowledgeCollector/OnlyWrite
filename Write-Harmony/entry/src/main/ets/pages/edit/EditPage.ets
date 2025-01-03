import web_webview from '@ohos.web.webview';
import { NoteBean } from '../../bean/NoteBean';
import { App, LengthMetrics, router } from '@kit.ArkUI';
import { CommUtils } from '../../utils/CommUtils';
import { AppUtil, DialogUtil, EmitterUtil, PreferencesUtil, ToastUtil } from '@pura/harmony-utils';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { MdMenuBean } from '../../bean/MdMenuBean';
import { EditUtils } from '../../utils/EditUtils';
import { MdGridDialog } from '../dialog/MdGridDialog';
import { MdLinkDialog } from '../dialog/MdLinkDialog';
import { NoteDbManager } from '../../model/db/NoteDbManager';
import { NoteUtils } from '../../utils/NoteUtils';
import { Constants } from '../../utils/Constants';
import { AppTipDialog } from '../dialog/AppTipDialog';
import { PageBean } from '../../bean/PageBean';
import { TypeEditDialog } from '../dialog/TypeEditDialog';

@Entry
@Component
struct EditPage {
  webController: web_webview.WebviewController = new web_webview.WebviewController();
  titlController: TextInputController = new TextInputController()
  contentController: TextInputController = new TextInputController()
  //主题
  @State themeNight: boolean = false
  //手势类型
  @State dragType: number = 0
  //正文排版
  @State textAlign: number = 0
  //标题字号
  @State titlteSize: number = 18
  //正文字号
  @State contentSize: number = 16
  //正文边距
  @State contentPadding: number = 20
  //正文字间距
  @State wordPadding: number = 1.5
  //正文行间距
  @State linePadding: number = 10
  //软键盘显隐
  @State inputBoardShow: boolean = false
  //正文编辑状态
  @State isContentEdit: boolean = false
  //光标
  @State cousorStart: number = 0
  @State cousorEnd: number = 0
  //md菜单滑动
  scroller: Scroller = new Scroller()
  @State currentOffset: number = 0
  //当前编辑文章
  @State noteBean: NoteBean | null = null
  @State noteId: number = 0
  //标题
  @State title: string = ""
  //正文
  @State content: string = ""
  //是否预览
  @State isPreview: boolean = false
  //壁纸
  @State bgResource: Resource = $r('app.media.white')
  //字体颜色
  @State textColor: Resource = $r('sys.color.black')
  //新增
  @State addBtn: Resource = $r('app.media.add_black')
  //预览
  @State previewBtn: Resource = $r('app.media.preview_black')
  //编辑
  @State editBtn: Resource = $r('app.media.edit_black')
  //左侧边栏
  @State leftBtn: Resource = $r('app.media.arr_left_black')
  //右侧边栏
  @State righyBtn: Resource = $r('app.media.arr_right_black')
  //隐私政策
  pravicyAgree: boolean = false
  //隐私政策弹窗
  appHintController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: AppTipDialog({
      publish: () => {
        this.pravicyAgree = true
        PreferencesUtil.put(Constants.App_Pravicy, true)
        //操作提示1
        if (!this.LeftDrawerTip) {
          this.showLeftTip()
        }
      },
      cancel: () => {
        router.back()
      }
    })
  });
  //左侧边栏提示
  LeftDrawerTip: boolean = false
  //右侧边栏提示
  righyDrawerTip: boolean = false

  showLeftTip() {
    this.LeftDrawerTip = true
    PreferencesUtil.putSync("left_drawer_tip", true)
    DialogUtil.showPrimaryDialog({
      title: $r('app.string.note_page'),
      message: $r('app.string.left_page_tip'),
      primaryButton: {
        value: $r('app.string.confirm'),
        action: async () => {
          this.openPage(true)
        }
      }
    })
  }

  showRightTip() {
    this.righyDrawerTip = true
    PreferencesUtil.putSync("right_drawer_tip", true)
    DialogUtil.showPrimaryDialog({
      title: $r('app.string.setting_page'),
      message: $r('app.string.righy_page_tip'),
      primaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          this.openPage(false)
        }
      }
    })
  }

  pageTransition() {
    if (this.dragType == 1) {
      PageTransitionEnter({ type: RouteType.None, duration: 250 }).slide(SlideEffect.Left)
      PageTransitionExit({ type: RouteType.None, duration: 250 }).slide(SlideEffect.Left)
    } else if (this.dragType == 2) {
      PageTransitionEnter({ type: RouteType.None, duration: 250 }).slide(SlideEffect.Right)
      PageTransitionExit({ type: RouteType.None, duration: 250 }).slide(SlideEffect.Right)
    }
  }

  aboutToAppear() {
    try {
      AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
      AppUtil.getMainWindow().on('keyboardHeightChange', (height) => {
        this.inputBoardShow = height > 0
      });
    } catch (exception) {
      console.error(`Failed to enable the listener for keyboard height changes`);
    }

    this.pravicyAgree = PreferencesUtil.getBooleanSync(Constants.App_Pravicy)
    this.LeftDrawerTip = PreferencesUtil.getBooleanSync("left_drawer_tip")
    this.righyDrawerTip = PreferencesUtil.getBooleanSync("right_drawer_tip")
    if (!this.pravicyAgree) {
      //展示默认文章
      setTimeout(() => {
        NoteDbManager.getInstance().getNoteByChapterId(1).then((notes) => {
          if (notes.length > 0) {
            this.selectNote(notes[0])
          }
        })
      }, 50);
    }
    //展示上次打开文章
    this.noteId = PreferencesUtil.getNumberSync(Constants.Key_NoteId, 0)
    NoteDbManager.getInstance().getNoteById(this.noteId).then((notes) => {
      if (notes.length > 0) {
        this.selectNote(notes[0])
      }
    })

    let styleIndex = PreferencesUtil.getNumberSync(Constants.Editor_Wallpaper)
    this.setEditStyle(styleIndex)
    this.setEditorSettings()
    EmitterUtil.onSubscribe<number>(Constants.Message_Delete_Current_Edit, (book) => {
      this.noteBean = null
    })
    EmitterUtil.onSubscribe<number>(Constants.Message_Restore, (book) => {
      this.noteBean = null
      PreferencesUtil.putSync(Constants.Key_NoteId, -1)
    })
    EmitterUtil.onSubscribe<number>(Constants.Message_Editor_Wallpaper, (index) => {
      PreferencesUtil.putSync(Constants.Editor_Wallpaper, index)
      this.setEditStyle(index)
    })
    EmitterUtil.onSubscribe<number>(Constants.Message_Editor_Setting, (index) => {
      this.setEditorSettings()
    })
  }

  onPageShow(): void {
    //隐私政策
    if (!this.pravicyAgree) {
      this.appHintController?.open()
    }

    //操作提示2
    if (this.LeftDrawerTip && !this.righyDrawerTip) {
      this.showRightTip()
    }

    //切换文章
    const params = this.getUIContext().getRouter().getParams() as Record<string, NoteBean>; // 获取传递过来的参数对象
    if (params) {
      let note: NoteBean = params.note as NoteBean
      this.selectNote(note)
    }
  }

  selectNote(note: NoteBean) {
    this.isContentEdit = false
    this.undoStack = [];
    this.redoStack = [];
    this.noteBean = note
    this.title = note.title
    this.content = note.content
    this.isPreview = note.isdelete
    PreferencesUtil.putSync(Constants.Key_NoteId, note.pageId)
    PreferencesUtil.putSync(Constants.Key_ChapterId, note.chapterId)
  }

  build() {
    Stack() {
      Image(this.bgResource)
        .height('100%').width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // 图片组件的绘制区域扩展至状态栏和导航条。

      Column() {
        if (this.isPreview && NoteUtils.hasMarkdown(this.content)) {
          //md预览
          Web({
            src: $rawfile(this.themeNight ? "markdown_night.html" : "markdown_day.html"),
            controller: this.webController
          })
            .layoutWeight(1)
            .fileAccess(true)
            .imageAccess(true)
            .margin({ left: this.contentPadding, right: this.contentPadding })
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .onlineImageAccess(true)
            .mixedMode(MixedMode.All)
            .onPageEnd((event) => {
              this.previewMd()
            })
            .backgroundColor(Color.Transparent)
        } else {
          //编辑
          if (this.noteBean) {
            Column() {
              //标题
              TextInput({
                text: this.title,
                placeholder: $r('app.string.title'),
                controller: this.titlController
              })
                .fontColor(this.textColor)
                .placeholderColor(this.textColor)
                .fontSize(this.titlteSize)
                .fontWeight(400)
                .enableKeyboardOnFocus(false)
                .backgroundColor(Color.Transparent)
                .margin({ top: 10, bottom: 0 })
                .padding({ left: this.contentPadding, right: this.contentPadding })
                .onChange((textInComment: string) => {
                  this.title = textInComment
                  if (this.noteBean) {
                    this.noteBean.title = textInComment
                    this.noteBean.editTime = Date.now()
                    NoteDbManager.getInstance().updateNote(this.noteBean)
                  }
                })

              //正文
              if (this.isPreview && !NoteUtils.hasMarkdown(this.content)) {
                Scroll() {
                  Text(this.content)
                    .fontColor(this.textColor)
                    .fontSize(this.contentSize)
                    .fontWeight(300)
                    .textAlign(TextAlign.Start)
                    .letterSpacing(this.wordPadding)
                    .lineSpacing(LengthMetrics.vp(this.linePadding))
                    .width('100%')
                }
                .padding({ top: 5, left: this.contentPadding, right: this.contentPadding })
                .margin({ bottom: 8 })
                .backgroundColor(Color.Transparent)
                .width('100%')
              } else {
                TextArea({
                  text: this.content,
                  placeholder: $r('app.string.write_something'),
                  controller: this.contentController
                })
                  .fontColor(this.textColor)
                  .placeholderColor(this.textColor)
                  .padding({ top: 5, left: this.contentPadding, right: this.contentPadding })
                  .width('100%')
                  .height('100%')
                  .fontWeight(300)
                  .fontSize(this.contentSize)
                  .letterSpacing(this.wordPadding)
                  .lineSpacing(LengthMetrics.vp(this.linePadding))
                  .backgroundColor(Color.Transparent)
                  .onEditChange((isEditing) => {
                    this.isContentEdit = isEditing
                    if (this.isContentEdit) {
                      setTimeout(() => {
                        this.scroller.scrollTo({ xOffset: this.currentOffset, yOffset: 0, animation: false })
                      }, 100)
                    }
                  })
                  .onChange((textInComment: string) => {
                    this.content = textInComment
                    if (this.noteBean) {
                      this.noteBean.content = textInComment
                      this.noteBean.editTime = Date.now()
                      NoteDbManager.getInstance().updateNote(this.noteBean)
                    }
                    // Save the current value before making a new change
                    if (this.currentInputValue !== textInComment) {
                      this.undoStack.push(this.currentInputValue);
                      this.undoIndex.push(this.cousorStart)
                      this.redoStack = []; // Clear redo stack when new input is made
                      this.redoIndex = []
                      this.currentInputValue = textInComment;
                    }
                  })
                  .onTextSelectionChange((start, end) => {
                    this.cousorStart = start
                    this.cousorEnd = end
                  })
              }
            }.layoutWeight(1)
            .width('100%')
            .margin({ bottom: 40 })
          } else {
            Column() {
              Text($r('app.string.empty_tip'))
                .fontColor(this.textColor)
                .fontSize(16)
                .fontWeight(300)
            }.layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .margin({ bottom: 40 })
          }
        }

        //底部菜单
        if (this.isContentEdit) {
          Column() {
            Line().backgroundColor($r('sys.color.ohos_id_color_sub_background')).height(1).width('100%')
            List({ scroller: this.scroller }) {
              ForEach(EditUtils.txtMenus, (item: MdMenuBean, index) => {
                ListItem() {
                  Image(item.icon)
                }.padding(12).layoutWeight(1).height('100%').onClick((event) => {
                  this.txtMenuClick(index)
                })
              })
              ForEach(EditUtils.mdMenus, (item: MdMenuBean, index) => {
                ListItem() {
                  Image(item.icon)
                }.padding(12).layoutWeight(1).height('100%').onClick((event) => {
                  this.mdMenuClick(item.menuId)
                })
              })
            }
            .onScrollStop(() => {
              this.currentOffset = this.scroller.currentOffset().xOffset
            })
            .scrollBar(BarState.Off)
            .listDirection(Axis.Horizontal)
            .height('100%')
            .width('100%')
          }.height(40).width('100%').backgroundColor(Color.White)
        } else if (!this.inputBoardShow) {
          Row() {
            Image(this.leftBtn)
              .height(20)
              .width(20)
              .margin({ right: 20 })
              .onClick((event) => {
                this.openPage(true)
              })
            Image(this.righyBtn)
              .height(20)
              .width(20)
              .onClick((event) => {
                this.openPage(false)
              })
            Blank()
            if (this.noteBean) {
              Image(this.isPreview ? this.editBtn : this.previewBtn)
                .height(20)
                .width(20)
                .margin({ right: 20 })
                .onClick((event) => {
                  this.isPreview = !this.isPreview
                  if (this.noteBean) {
                    this.noteBean.isdelete = this.isPreview
                    NoteDbManager.getInstance().updateNote(this.noteBean)
                  }
                })
            }
            Image(this.addBtn).height(20).width(20).onClick((event) => {
              //新增文章
              let note =
                new NoteBean(Math.round(Date.now() / 1000), PreferencesUtil.getNumberSync(Constants.Key_ChapterId), "",
                  "", Date.now(), Date.now(), false, 0, 0)
              NoteDbManager.getInstance().insertNote(note).then((ok) => {
                this.selectNote(note)
              })
            })
          }
          .width('100%')
          .height(40)
          .padding({ left: 20, right: 20, top: 5 })
          .alignItems(VerticalAlign.Center)
        }
      }
      .gesture(SwipeGesture({ direction: SwipeDirection.Horizontal }).onAction((event) => {
        if (event && event.speed > 1000) {
          if (Math.abs(event.angle) > 100) {
            this.openPage(false)
          } else {
            this.openPage(true)
          }
        }
      }))
    }.height('100%').width('100%')
  }

  openPage(left: boolean) {
    if (left) {
      //切换文章
      this.dragType = 2
      CommUtils.openPage("pages/edit/LeftPage", new PageBean("pages/edit/EditPage"))
    } else {
      //设置
      this.dragType = 1
      CommUtils.openPage("pages/edit/RightPage", new PageBean("pages/edit/EditPage"))
    }
  }

  //txt菜单事件
  async txtMenuClick(index: number) {
    if (index == 1) {
      this.undo()
    } else if (index == 2) {
      this.redo()
    } else {
      let map = await EditUtils.txtMenuClick(index, this.content, this.cousorStart, this.cousorEnd)
      this.content = map.get(0) as string
      let currentSelection = map.get(1) as number
      setTimeout(() => {
        this.contentController.setTextSelection(currentSelection, currentSelection)
      }, 50);
    }
  }

  //do,undo存储栈
  undoStack: Array<string> = [];
  undoIndex: Array<number> = [];
  redoStack: Array<string> = [];
  redoIndex: Array<number> = [];
  currentInputValue: string = '';

  //撤销
  undo() {
    if (this.undoStack.length > 0) {
      this.redoStack.push(this.currentInputValue);
      this.redoIndex.push(this.cousorStart)
      this.currentInputValue = this.undoStack.pop() as string;
      this.content = this.currentInputValue;
      let cousorStart = this.undoIndex.pop() as number
      setTimeout(() => {
        this.contentController.caretPosition(cousorStart)
      }, 50);
    }
  }

  //恢复
  redo() {
    if (this.redoStack.length > 0) {
      this.undoStack.push(this.currentInputValue);
      this.undoIndex.push(this.cousorStart)
      this.currentInputValue = this.redoStack.pop() as string;
      this.content = this.currentInputValue;
      let cousorStart = this.redoIndex.pop() as number
      setTimeout(() => {
        this.contentController.caretPosition(cousorStart)
      }, 50);
    }
  }

  //md语法菜单事件
  mdMenuClick(index: number) {
    if (index == 6) {
      this.colorPickerIndex = 6
      this.colorPickerTxt = this.content.substring(this.cousorStart, this.cousorEnd)
      this.colorPickerDialogController?.open()
    } else if (index == 7) {
      this.colorPickerIndex = 7
      this.colorPickerTxt = this.content.substring(this.cousorStart, this.cousorEnd)
      this.colorPickerDialogController?.open()
    } else if (index == 20) {
      this.insertLinkOrImg(false)
    } else if (index == 22) {
      this.insertGrid()
    } else if (index == 23) {
      this.insertLinkOrImg(true)
    } else {
      let map = EditUtils.mdMenuClick(index, this.content, this.cousorStart, this.cousorEnd)
      this.setMdMenuResult(map)
    }
  }

  //分类编辑弹窗
  colorPickerIndex = 0
  @State colorPickerTxt: string = ""
  colorPickerDialogController: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    builder: TypeEditDialog({
      txt: this.colorPickerTxt,
      colorId: "#000000",
      publish: async (txt, colorId) => {
        if (this.colorPickerIndex == 6) {
          let map = EditUtils.fontColor(this.content, txt, colorId, this.cousorStart, this.cousorEnd)
          this.setMdMenuResult(map)
        } else if (this.colorPickerIndex == 7) {
          let map = EditUtils.fontBgColor(this.content, txt, colorId, this.cousorStart, this.cousorEnd)
          this.setMdMenuResult(map)
        }
      }
    })
  });

  //插入表格
  insertGrid() {
    let editDialogController: CustomDialogController | null = new CustomDialogController({
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Bottom,
      builder: MdGridDialog({
        publish: async (row, column) => {
          if (row > 0 && column > 0) {
            let map = EditUtils.Grid(this.content, this.cousorStart, this.cousorEnd, row, column)
            this.setMdMenuResult(map)
          }
          editDialogController?.close()
        }
      })
    });
    editDialogController?.open()
  }

  //插入链接
  insertLinkOrImg(isLink: boolean) {
    let editDialogController: CustomDialogController | null = new CustomDialogController({
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Bottom,
      builder: MdLinkDialog({
        publish: async (title, url) => {
          if (title.length > 0 && url.length > 0) {
            if (isLink) {
              let map = EditUtils.Link(this.content, this.cousorStart, this.cousorEnd, title, url)
              this.setMdMenuResult(map)
            } else {
              let map = EditUtils.Img(this.content, this.cousorStart, this.cousorEnd, title, url)
              this.setMdMenuResult(map)
            }
          }
          editDialogController?.close()
        }
      })
    });
    editDialogController?.open()
  }

  //点击后菜单结果更新
  setMdMenuResult(map: Map<number, string | number>, delay: number = 50) {
    this.content = map.get(0) as string
    let currentSelection = map.get(1) as number
    setTimeout(() => {
      this.contentController.caretPosition(currentSelection)
    }, delay);
  }

  //预览
  previewMd() {
    //安卓行内公式是$$，需要正则将行内$$替换为单$
    let noteTxt = "## " + this.title + "\n\n\n\n" +
    this.content.replace(/(?<!\n)\$\$/g, '$');
    noteTxt = noteTxt.replace("bgfont", "font")
    let newTxt = CommUtils.base64Encoder(noteTxt)
    this.webController.runJavaScript('parseMarkdown("' + newTxt + '")');
  }

  setEditStyle(index: number) {
    if (index == 0 || index == 2 || index == 4) {
      //浅色
      this.themeNight = false
      if (index == 0) {
        this.bgResource = $r('app.media.white')
      } else if (index == 2) {
        this.bgResource = $r('app.media.aa')
      } else if (index == 4) {
        this.bgResource = $r('app.media.dd')
      }
    }
    if (index == 1 || index == 3 || index == 5) {
      //深色
      this.themeNight = true
      if (index == 1) {
        this.bgResource = $r('app.media.black')
      } else if (index == 3) {
        this.bgResource = $r('app.media.bb')
      } else if (index == 5) {
        this.bgResource = $r('app.media.cc')
      }
    }
    this.textColor = $r(this.themeNight ? 'sys.color.white' : 'sys.color.black')
    this.addBtn = $r(this.themeNight ? 'app.media.add_white' : 'app.media.add_black')
    this.editBtn = $r(this.themeNight ? 'app.media.edit_white' : 'app.media.edit_black')
    this.previewBtn = $r(this.themeNight ? 'app.media.preview_white' : 'app.media.preview_black')
    this.leftBtn = $r(this.themeNight ? 'app.media.arr_left_white' : 'app.media.arr_left_black')
    this.righyBtn = $r(this.themeNight ? 'app.media.arr_right_white' : 'app.media.arr_right_black')
    this.setWebTheme(this.themeNight)
    CommUtils.setStatusBar({ statusBarContentColor: this.themeNight ? "#ffffff" : "#000000" })
  }

  setWebTheme(night: boolean) {
    try {
      if (!night) {
        this.webController.loadUrl($rawfile('markdown_day.html'))
      } else {
        this.webController.loadUrl($rawfile('markdown_night.html'))
      }
    } catch (err) {
    }
  }

  setEditorSettings() {
    this.textAlign = PreferencesUtil.getNumberSync(Constants.Editor_TextAlign, this.textAlign)
    this.titlteSize = PreferencesUtil.getNumberSync(Constants.Editor_TitlteSize, this.titlteSize)
    this.contentSize = PreferencesUtil.getNumberSync(Constants.Editor_ContentSize, this.contentSize)
    this.contentPadding = PreferencesUtil.getNumberSync(Constants.Editor_ContentPadding, this.contentPadding)
    this.wordPadding = PreferencesUtil.getNumberSync(Constants.Editor_WordPadding, this.wordPadding)
    this.linePadding = PreferencesUtil.getNumberSync(Constants.Editor_LinePadding, this.linePadding)
  }

  aboutToDisappear(): void {
    AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }
}