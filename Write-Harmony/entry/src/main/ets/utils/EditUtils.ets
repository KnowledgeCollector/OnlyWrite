import { DialogUtil, PasteboardUtil, PermissionUtil } from "@pura/harmony-utils";
import { MdMenuBean } from "../bean/MdMenuBean";
import { MdGridDialog } from "../pages/dialog/MdGridDialog";

export class EditUtils {
  public static txtMenus: Array<MdMenuBean> = [
    new MdMenuBean(0, "缩进", $r('app.media.txt_indent')),
    // new MdMenuBean(1, "粘贴", $r('app.media.txt_paste')),
    new MdMenuBean(2, "撤销", $r('app.media.txt_undo')),
    new MdMenuBean(3, "恢复", $r('app.media.txt_redo')),
  ]
  public static mdMenus: Array<MdMenuBean> = [
    new MdMenuBean(0, "加粗", $r('app.media.md_blod')),
    new MdMenuBean(1, "斜体", $r('app.media.md_italic')),
    new MdMenuBean(2, "引用", $r('app.media.md_quote')),
    new MdMenuBean(3, "分割线", $r("app.media.md_line")),
    new MdMenuBean(4, "横线", $r("app.media.md_though")),
    new MdMenuBean(5, "下划线", $r('app.media.md_underline')),
    new MdMenuBean(6, "字体颜色", $r('app.media.md_fontcolor')),
    new MdMenuBean(7, "背景颜色", $r('app.media.md_bgcolor')),
    new MdMenuBean(8, "无序列表", $r('app.media.md_list')),
    new MdMenuBean(9, "有序列表", $r('app.media.md_orderlist')),
    new MdMenuBean(10, "待办", $r('app.media.md_undo')),
    new MdMenuBean(11, "已办", $r('app.media.md_do')),
    new MdMenuBean(12, "标题1", $r('app.media.md_h1')),
    new MdMenuBean(13, "标题2", $r('app.media.md_h2')),
    new MdMenuBean(14, "标题3", $r('app.media.md_h3')),
    new MdMenuBean(15, "标题4", $r('app.media.md_h4')),
    new MdMenuBean(16, "标题5", $r('app.media.md_h5')),
    new MdMenuBean(17, "标题6", $r('app.media.md_h6')),
    new MdMenuBean(20, "网络图片", $r('app.media.md_img')),
    new MdMenuBean(22, "表格", $r('app.media.md_grid')),
    new MdMenuBean(23, "链接", $r('app.media.md_link')),
    new MdMenuBean(25, "Latex内联", $r('app.media.md_math_inline')),
    new MdMenuBean(26, "Latex块", $r('app.media.md_math_block')),
    new MdMenuBean(27, "代码块", $r('app.media.md_code')),
  ]
  public static orderList = 0

  public static mdMenuClick(menuId: number, str: string, cousorStart: number,
    cousorEnd: number): Map<number, string | number> {
    if (menuId != 9) {
      EditUtils.orderList = 0
    } else {
      EditUtils.orderList++
    }
    if (menuId == 0) {
      return EditUtils.Blod(str, cousorStart, cousorEnd)
    } else if (menuId == 1) {
      return EditUtils.Italic(str, cousorStart, cousorEnd)
    } else if (menuId == 2) {
      return EditUtils.Quote(str, cousorStart, cousorEnd)
    } else if (menuId == 3) {
      return EditUtils.Line(str, cousorStart, cousorEnd)
    } else if (menuId == 4) {
      return EditUtils.Though(str, cousorStart, cousorEnd)
    } else if (menuId == 5) {
      return EditUtils.Underline(str, cousorStart, cousorEnd)
    } else if (menuId == 8) {
      return EditUtils.List(str, cousorStart, cousorEnd)
    } else if (menuId == 9) {
      return EditUtils.OrderList(str, cousorStart, cousorEnd)
    } else if (menuId == 10) {
      return EditUtils.Undo(str, cousorStart, cousorEnd)
    } else if (menuId == 11) {
      return EditUtils.Do(str, cousorStart, cousorEnd)
    } else if (menuId >= 12 && menuId <= 17) {
      return EditUtils.H(str, cousorStart, cousorEnd, menuId - 11)
    } else if (menuId == 25) {
      return EditUtils.MathInline(str, cousorStart, cousorEnd)
    } else if (menuId == 26) {
      return EditUtils.MathBlock(str, cousorStart, cousorEnd)
    } else if (menuId == 27) {
      return EditUtils.Code(str, cousorStart, cousorEnd)
    } else {
      return new Map<number, string>()
    }
  }


  //加粗
  public static Blod(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = " **" + substring + "** "
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 3
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //斜体
  public static Italic(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = " *" + substring + "* "
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 2
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //引用
  public static Quote(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "> " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //分割线
  public static Line(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "\n-------\n"
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //中间线
  public static Though(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = " ~~" + substring + "~~ "
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 3
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //下划线
  public static Underline(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "<u>" + substring + "</u>"
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 4
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //字体颜色
  public static fontColor(source: string, colorTxt: string, colorId: string, cousorStart: number,
    cousorEnd: number): Map<number, string | number> {
    let result = "<font color=\"" + colorId + "\">" + colorTxt + "</font>";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 7
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //背景颜色
  public static fontBgColor(source: string, colorTxt: string, colorId: string, cousorStart: number,
    cousorEnd: number): Map<number, string | number> {
    let result = "<bgfont color=\"" + colorId + "\">" + colorTxt + "</bgfont>";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 9
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //无序列表
  public static List(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "- " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }


  //有序列表
  public static OrderList(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = EditUtils.orderList + ". " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //待办
  public static Undo(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "- [ ] " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //已办
  public static Do(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "- [x] " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //标题
  public static H(source: string, cousorStart: number, cousorEnd: number,
    hcount: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd);
    let result = ""
    for (let i = 0; i < hcount; i++) {
      result += "#"
    }
    result += " " + substring
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //在线图片
  public static Img(source: string, cousorStart: number, cousorEnd: number, title: string,
    url: string): Map<number, string | number> {
    let result = "![" + title + "](" + url + ")";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //表格
  public static Grid(source: string, cousorStart: number, cousorEnd: number, row: number,
    column: number): Map<number, string | number> {
    let result = "\n|"
    for (let i = 0; i < column; i++) {
      result += " Header |"
    }
    result += "\n|"
    for (let i = 0; i < column; i++) {
      result += ":----------:|"
    }
    result += "\n"
    for (let i2 = 0; i2 < row; i2++) {
      result += "|"
      for (let i = 0; i < column; i++) {
        result += "            |"
      }
      result += "\n"
    }
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }


  //链接
  public static Link(source: string, cousorStart: number, cousorEnd: number, title: string,
    url: string): Map<number, string | number> {
    let result = "[" + title + "](" + url + ")";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //内联函数
  public static MathInline(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "$$" + substring + "$$";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 2
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //块函数
  public static MathBlock(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "\n$$\n" + substring + "\n$$\n";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 4
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //代码块
  public static Code(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = "\n```\n" + substring + "\n\n```\n";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length - 6
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  public static async txtMenuClick(menuId: number, str: string, cousorStart: number,
    cousorEnd: number): Promise<Map<number, string | number>> {
    if (menuId == 0) {
      return EditUtils.Indent(str, cousorStart, cousorEnd)
    }
    // else if (menuId == 1) {
    //   return await EditUtils.Paste(str, cousorStart, cousorEnd)
    // }
    else {
      return new Map<number, string>()
    }
  }

  //缩进
  public static Indent(source: string, cousorStart: number, cousorEnd: number): Map<number, string | number> {
    let substring = source.substring(cousorStart, cousorEnd)
    let result = substring + "\u3000\u3000";
    let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
    let newSelection = cousorStart + result.length
    let map = new Map<number, string | number>()
    map.set(0, txt)
    map.set(1, newSelection)
    return map
  }

  //粘贴
  public static async Paste(source: string, cousorStart: number,
    cousorEnd: number): Promise<Map<number, string | number>> {
    let hasPermission = await PermissionUtil.checkPermissions('ohos.permission.READ_PASTEBOARD')
    if (!hasPermission) {
      //没权限弹窗申请权限
      let userOk = await new Promise<boolean>((resolve) => {
        DialogUtil.showPrimaryDialog({
          title: $r('app.string.hint'),
          message: $r('app.string.permission_reason_pasteboard'),
          autoCancel: true,
          primaryButton: {
            value: $r('app.string.cancel'),
            action: () => {
              resolve(false)
            }
          },
          secondaryButton: {
            value: $r('app.string.confirm'),
            action: () => {
              resolve(true)
            }
          }
        })
      })
      if (userOk) {
        //去申请权限
        hasPermission = await PermissionUtil.requestPermissionsEasy('ohos.permission.READ_PASTEBOARD')
      }
    }
    let map = new Map<number, string | number>()
    if (hasPermission) {
      //有权限
      let substring = source.substring(cousorStart, cousorEnd)
      let paste = PasteboardUtil.getDataSyncStr()
      let result = substring + paste;
      let txt = EditUtils.insertString(source, result, cousorStart, cousorEnd)
      let newSelection = cousorStart + result.length
      map.set(0, txt)
      map.set(1, newSelection)
      return map
    } else {
      map.set(0, source)
      map.set(1, cousorStart)
      return map
    }
  }

  public static insertString(original: string, insert: string, cousorStart: number, cousorEnd: number): string {
    const startTxt = original.slice(0, cousorStart);
    const middle = insert;
    const endTxt = original.slice(cousorEnd);
    return startTxt + middle + endTxt;
  }
}
