import { TitleBar } from '../../widget/TitleBar';
import { TextPreference } from '../../widget/TextPreference';
import { EmitterUtil, NumberUtil, PreferencesUtil, ResUtil } from '@pura/harmony-utils';
import { Constants } from '../../utils/Constants';
import { RadioDialog } from '../dialog/RadioDialog';
import { RadioMenuBean } from '../../bean/RadioMenuBean';
import { InputDialog } from '../dialog/InputDialog';

@Entry
@Component
struct SettingPage {
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

  aboutToAppear(): void {
    this.textAlign = PreferencesUtil.getNumberSync(Constants.Editor_TextAlign, this.textAlign)
    this.titlteSize = PreferencesUtil.getNumberSync(Constants.Editor_TitlteSize, this.titlteSize)
    this.contentSize = PreferencesUtil.getNumberSync(Constants.Editor_ContentSize, this.contentSize)
    this.contentPadding = PreferencesUtil.getNumberSync(Constants.Editor_ContentPadding, this.contentPadding)
    this.wordPadding = PreferencesUtil.getNumberSync(Constants.Editor_WordPadding, this.wordPadding)
    this.linePadding = PreferencesUtil.getNumberSync(Constants.Editor_LinePadding, this.linePadding)
  }

  build() {
    Column() {
      TitleBar({ title: $r('app.string.likesetting') })
      Column() {
        Column() {
          Text($r('app.string.editor')).fontSize(16).fontColor($r('sys.color.ohos_id_text_color_active'))
          TextPreference({
            title: $r('app.string.text_align'),
            content: ResUtil.getStringSync(this.textAlign == 0 ? $r('app.string.align_left') :
              this.textAlign == 1 ? $r('app.string.align_center') : $r('app.string.align_right'))
          }).onClick((event) => {
            this.textAlignDialog?.open()
          })
          TextPreference({ title: $r('app.string.title_size'), content: this.titlteSize.toString() })
            .onClick((event) => {
              this.editDialog(this.titlteSize.toString(), (size: string) => {
                this.titlteSize = NumberUtil.toInt(size)
                PreferencesUtil.putSync(Constants.Editor_TitlteSize, this.titlteSize)
                EmitterUtil.post<number>(Constants.Message_Editor_Setting, 0)
              })
            })
          TextPreference({ title: $r('app.string.content_size'), content: this.contentSize.toString() })
            .onClick((event) => {
              this.editDialog(this.contentSize.toString(), (size: string) => {
                this.contentSize = NumberUtil.toInt(size)
                PreferencesUtil.putSync(Constants.Editor_ContentSize, this.contentSize)
                EmitterUtil.post<number>(Constants.Message_Editor_Setting, 0)
              })
            })
          TextPreference({ title: $r('app.string.content_padding'), content: this.contentPadding.toString() })
            .onClick((event) => {
              this.editDialog(this.contentPadding.toString(), (size: string) => {
                this.contentPadding = NumberUtil.toInt(size)
                PreferencesUtil.putSync(Constants.Editor_ContentPadding, this.contentPadding)
                EmitterUtil.post<number>(Constants.Message_Editor_Setting, 0)
              })
            })
          TextPreference({ title: $r('app.string.letter_padding'), content: this.wordPadding.toString() })
            .onClick((event) => {
              this.editDialog(this.wordPadding.toString(), (size: string) => {
                this.wordPadding = NumberUtil.toFloat(size)
                PreferencesUtil.putSync(Constants.Editor_WordPadding, this.wordPadding)
                EmitterUtil.post<number>(Constants.Message_Editor_Setting, 0)
              })
            })
          TextPreference({ title: $r('app.string.line_padding'), content: this.linePadding.toString() })
            .onClick((event) => {
              this.editDialog(this.linePadding.toString(), (size: string) => {
                this.linePadding = NumberUtil.toInt(size)
                PreferencesUtil.putSync(Constants.Editor_LinePadding, this.linePadding)
                EmitterUtil.post<number>(Constants.Message_Editor_Setting, 0)
              })
            })
        }
        .width('100%')
        .borderRadius(10)
        .padding(20)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

      }
      .padding({ left: 15, right: 15, top: 15 })
      .height('100%')
      .width('100%')
    }.height('100%')
    .width('100%')
  }

  editDialog(text: string, listener: Function) {
    let controller = new CustomDialogController({
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Bottom,
      builder: InputDialog({
        content: text,
        inputType: InputType.Number,
        publish: (text) => {
          controller.close()
          listener(text)
        }
      })
    })
    controller.open();
  }

  //排序菜单弹窗
  textAlignDialog: CustomDialogController | null = new CustomDialogController({
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    builder: RadioDialog({
      titlt: $r('app.string.text_align'),
      menus: [
        new RadioMenuBean($r('app.string.align_left'), this.textAlign == 0),
        new RadioMenuBean($r('app.string.align_center'), this.textAlign == 1),
        new RadioMenuBean($r('app.string.align_right'), this.textAlign == 2),
      ],
      itemClick: (index) => {
        this.textAlign = index
        PreferencesUtil.putSync(Constants.Editor_TextAlign, index)
      }
    })
  });
}