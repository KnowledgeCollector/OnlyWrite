import { systemDateTime } from "@kit.BasicServicesKit";
import { DateUtil } from "@pura/harmony-utils";

export class NoteUtils {
  /**
   * 格式化时间
   * @param timestamp 时间戳
   * @returns 几小时前，超过24小时，显示日期
   */
  public static formatTime(timestamp: number): string {
    try {
      let currentTime = systemDateTime.getTime(false)
      let diff = currentTime - timestamp
      const secondsAgo = (currentTime - timestamp) / 1000;
      if (secondsAgo < 60) {
        return '刚刚';
      } else if (secondsAgo < 60 * 60) {
        return `${Math.floor(secondsAgo / 60)}分钟前`;
      } else if (secondsAgo < 60 * 60 * 24) {
        return `${Math.floor(secondsAgo / (60 * 60))}小时前`;
      } else {
        let year = new Date().getFullYear()
        let date = DateUtil.getFormatDateStr(timestamp, 'yyyy-MM-dd')
        let dateStr = date.split("-")
        if (year.toString() === dateStr[0]) {
          return dateStr[1] + "/" + dateStr[2]
        } else {
          return date
        }
      }
    } catch (e) {
      return ""
    }
  }

  public static getNoteTime(time: number) {
    return DateUtil.getFormatDateStr(time, 'yyyy-MM-dd HH:mm')
  }

  public static getNoteTimeTwo(time: number) {
    return DateUtil.getFormatDateStr(time, 'yyyy-MM-dd HH:mm:ss')
  }

  public static getBackUpTime(time: number) {
    return DateUtil.getFormatDateStr(time, 'yyyyMMddHHmm')
  }

  /**
   * 显示类型文本
   * @param action 0是txt，1是markdown，2是html，3是思维导图mind，4是大纲笔记outline
   */
  public static getNoteAction(action: number):
    string {
    switch (action) {
      case 0:
        return "txt"
      case 1:
        return "md"
      case 2:
        return "html"
      case 3:
        return "mind"
      case 4:
        return "outline"
      default:
        return ""
    }
  }

  public static getNoteCount(str: string) {
    // 定义正则表达式，匹配字母、数字和汉字
    const regex = /[\p{L}\p{Nd}\p{Script=Han}]/gu;
    const matches = str.match(regex);
    const count = matches ? matches.length : 0;
    return count
  }

  public static getNoteMedias(markdown: string): Array<string> {
    let medias: Array<string> = []
    // 正则表达式匹配Markdown中的图片链接
    const imageUrlRegex = /!\[.*?\]\((.*?)(?:\s+".*?")?\)/g;
    let match: RegExpExecArray | null;
    // 使用全局匹配找到所有符合条件的字符串
    while ((match = imageUrlRegex.exec(markdown)) !== null) {
      // match[1] 是捕获组，包含图片链接
      medias.push(match[1] as string);
    }
    return medias;
  }


  public static  hasMarkdown(text: string): Boolean {
    if (text.includes("# ")) return true
    if (text.includes("-------")) return true
    if (text.includes("<font color=") && text.includes("</font>")) return true
    if (text.includes("<bgfont color=") && text.includes("</bgfont>")) return true
    if (text.includes("- [ ] ")) return true
    if (text.includes("- [x] ")) return true
    if (text.includes("- ")) return true
    if (text.includes("> ")) return true
    if (text.includes("0. ")) return true
    if (text.includes("1. ")) return true
    if (text.includes("2. ")) return true
    if (text.includes("3. ")) return true
    if (text.includes("4. ")) return true
    if (text.includes("5. ")) return true
    if (text.includes("6. ")) return true
    if (text.includes("7. ")) return true
    if (text.includes("8. ")) return true
    if (text.includes("9. ")) return true
    if (text.includes("](http ")) return true
    if (text.includes(":----------:|")) return true
    if (NoteUtils.countStr(text, "$$") > 1) return true
    if (NoteUtils.countStr(text, "*") > 1) return true
    if (NoteUtils.countStr(text, "**") > 1) return true
    if (NoteUtils.countStr(text, "~~") > 1) return true
    if (NoteUtils.countStr(text, "```") > 1) return true
    if (text.includes("<u>") && text.includes("</u>")) return true
    return false
  }

  /**
   * 判断str1中包含str2的个数
   */
  public static  countStr(str1: string, str2: string): number {
    let fromIndex = 0
    let count = 0
    while (true) {
      let index = str1.indexOf(str2, fromIndex)
      if (-1 != index) {
        fromIndex = index + 1
        count++
      } else {
        break
      }
    }
    return count
  }


}
