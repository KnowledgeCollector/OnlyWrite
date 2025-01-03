import { router, window } from "@kit.ArkUI";
import { buffer, util } from "@kit.ArkTS";
import { ChapterBean } from "../bean/ChapterBean";
import { BookBean } from "../bean/BookBean";
import { common } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { systemShare } from "@kit.ShareKit";
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { PageBean } from "../bean/PageBean";
import { AppUtil } from "@pura/harmony-utils";

export class CommUtils {
  //打开页面
  public static openPage(page: string, data: BookBean | ChapterBean | PageBean) {
    router.pushUrl({
      url: page, params: data
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Open Page ${page} failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
    });
  }

  public static replacePage(page: string, data: BookBean | ChapterBean | PageBean) {
    router.replaceUrl({
      url: page, params: data
    }, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Open Page ${page} failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
    });
  }

  //base64编码
  public static base64Encoder(str: string): string {
    let strArray = new Uint8Array(buffer.from(str).buffer)
    let base64 = new util.Base64Helper();
    let ret = base64.encodeToStringSync(strArray, util.Type.BASIC)
    return ret;
  }

  //分享
  public static shareTxt(context: common.UIAbilityContext, title: string, content: string): void {
    // 构造ShareData，需配置一条有效数据信息
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.TEXT,
      title: title, // 不传title字段时,显示content
      content: content,
    });
    // 进行分享面板显示
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    controller.show(context, {
      selectionMode: systemShare.SelectionMode.SINGLE,
      previewMode: systemShare.SharePreviewMode.DETAIL,
    }).then(() => {
      console.info('ShareController show success.');
    }).catch((error: BusinessError) => {
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    });
  }

  public static setStatusBar(systemBarProperties?: window.SystemBarProperties) {
    try {
      let windowClass = AppUtil.getMainWindow();
      if (systemBarProperties) {
        windowClass.setWindowSystemBarProperties(systemBarProperties).catch((error: BusinessError) => {
        });
      }
    } catch (err) {
    }
  }
}