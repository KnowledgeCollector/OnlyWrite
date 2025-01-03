import { NoteBean } from "../bean/NoteBean"
import { AppHelper } from "../utils/AppHelper";
import { NoteUtils } from "../utils/NoteUtils"

@Component
export struct NoteItem {
  @Prop selctNoteId: number = 0
  @Prop noteBean: NoteBean
  itemClick: () => void = (): void => {
  }
  itemLongClick: () => void = (): void => {
  }

  build() {
    Column() {
      //标题
      Text(this.noteBean.title).fontSize(16).fontWeight(400).fontColor($r('sys.color.black'))
      //内容
      Text(this.noteBean.content.length > 60 ? this.noteBean.content.substring(0, 60) : this.noteBean.content)
        .fontWeight(200)
        .maxLines(4)
        .margin({ top: 10 })
        .fontSize(12)
      //底部-时间
      Row() {
        Text((AppHelper.sortType == 1 ? "更新于" : "创建于") +
        NoteUtils.formatTime(AppHelper.sortType == 1 ? this.noteBean.editTime : this.noteBean.createTime) + "," +
        NoteUtils.getNoteCount(this.noteBean.content) + "字")
          .fontSize(12)
          .fontWeight(200)
          .fontColor(Color.Grey)
      }.margin({ top: 10 }).width('100%')
    }
    .padding(15)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.noteBean.pageId == this.selctNoteId ? $r('sys.color.ohos_id_color_sub_background') :
    $r('sys.color.white'))
    .onClick((event) => {
      this.itemClick()
    })
    .gesture(LongPressGesture({ repeat: false })
      .onActionEnd(() => {
        if (this.itemLongClick) {
          this.itemLongClick()
        }
      }))
  }
}
