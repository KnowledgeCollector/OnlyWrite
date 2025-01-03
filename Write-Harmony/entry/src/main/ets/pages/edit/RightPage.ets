import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommUtils } from '../../utils/CommUtils';
import { EmitterUtil, PreferencesUtil, ToastUtil, WantUtil } from '@pura/harmony-utils';
import { PageBean } from '../../bean/PageBean';
import { common } from '@kit.AbilityKit';
import { Constants } from '../../utils/Constants';
import { router } from '@kit.ArkUI';
import { BackUpManager } from '../../model/backup/BackUpManager';
import { RestoreDialog } from '../dialog/RestoreDialog';
import { AliyunFile } from '../../bean/AliyunFile';
import { BaiduListlFile } from '../../bean/BaiduListFile';

@Entry
@Component
struct RightPage {
  @State versionName: string = ""
  @State isAliyunOpen: boolean = false
  @State isBaiduOpen: boolean = false

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 250 }).slide(SlideEffect.Right)
    PageTransitionExit({ type: RouteType.Pop, duration: 250 }).slide(SlideEffect.Right)
  }

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      //应用版本名
      this.versionName = "V" + bundleInfo.versionName
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
  }

  onPageShow(): void {
    this.isAliyunOpen = PreferencesUtil.getBooleanSync("aliyunpan_backup");
    this.isBaiduOpen = PreferencesUtil.getBooleanSync("baiduyun_backup");
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.app_icon')).width(100).height(100)
        Column() {
          Text($r('app.string.app_name')).fontWeight(400).fontSize(20)
          Text($r('app.string.app_des')).fontWeight(300).fontSize(12).margin({ top: 10 })
        }.alignItems(HorizontalAlign.Start)
      }.justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
      .width('100%')

      Row() {
        Column() {
          Image($r('app.media.webdav')).width(20).height(20)
          Text(false ? $r('app.string.grant') : $r('app.string.ungrant')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          ToastUtil.showToast('加紧开发中')
          // CommUtils.openPage("pages/setting/CloudPage", new PageBean())
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.aliyun')).width(20).height(20)
          Text(this.isAliyunOpen ? $r('app.string.grant') : $r('app.string.ungrant')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          CommUtils.openPage("pages/setting/CloudPage", new PageBean())
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.baiduyun')).width(20).height(20)
          Text(this.isBaiduOpen ? $r('app.string.grant') : $r('app.string.ungrant')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          CommUtils.openPage("pages/setting/CloudPage", new PageBean())
        })

      }.padding({ left: 15, right: 15 })

      Row() {
        Column() {
          Image($r('app.media.backup')).width(20).height(20)
          Text($r('app.string.backup')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          BackUpManager.getInstance().backupLocal(getContext(this) as common.Context)
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.restore')).width(20).height(20)
          Text($r('app.string.retore_local')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          BackUpManager.getInstance().restoreLocal(getContext(this) as common.Context, () => {
            EmitterUtil.post<number>(Constants.Message_Restore, 0)
            ToastUtil.showToast($r('app.string.restore_ok'))
            CommUtils.replacePage("pages/edit/LeftPage", new PageBean("pages/edit/EditPage"))
          })
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.restore')).width(20).height(20)
          Text($r('app.string.restore_cloud')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          BackUpManager.getInstance().getCloud((result: Array<AliyunFile | BaiduListlFile>) => {
            let dataType = 0
            try {
              //1:阿里云 2：百度云
              if ((result[0] as AliyunFile).name.length > 0) {
                dataType = 1
              } else if ((result[0] as BaiduListlFile).server_filename.length > 0) {
                dataType = 2
              }
            } catch (e) {
            }
            let restoreDialogController: CustomDialogController | null = new CustomDialogController({
              autoCancel: true,
              customStyle: true,
              alignment: DialogAlignment.Bottom,
              builder: RestoreDialog({
                dataType: dataType,
                files: result,
                publish: async (index) => {
                  restoreDialogController?.close()
                  BackUpManager.getInstance().restoreCloud(index, () => {
                    EmitterUtil.post<number>(Constants.Message_Restore, 0)
                    ToastUtil.showToast($r('app.string.restore_ok'))
                    CommUtils.replacePage("pages/edit/LeftPage", new PageBean("pages/edit/EditPage"))
                  })
                }
              })
            });
            restoreDialogController.open()
          })
        })

      }.padding({ left: 15, right: 15 }).margin({ top: 10 })

      Row() {
        Text()
          .backgroundColor($r('sys.color.black'))
          .layoutWeight(1)
          .height('100%')
          .borderRadius(10)
          .onClick((event) => {
            EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 1)
            router.back()
          })
        Blank().width(10)
        Text()
          .backgroundColor($r('sys.color.white'))
          .layoutWeight(1)
          .height('100%')
          .layoutWeight(1)
          .borderRadius(10)
          .borderWidth(0.5)
          .borderColor(Color.Gray)
          .onClick((event) => {
            EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 0)
            router.back()
          })
      }.height(80).padding({ left: 15, right: 15 }).margin({ top: 10 })

      Row() {
        Image($r('app.media.aa')).layoutWeight(1).borderRadius(10).onClick((event) => {
          EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 2)
          router.back()
        })
        Blank().width(10)
        Image($r('app.media.bb')).layoutWeight(1).borderRadius(10).onClick((event) => {
          EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 3)
          router.back()
        })
      }.height(80).padding({ left: 15, right: 15 }).margin({ top: 10 })

      Row() {
        Image($r('app.media.cc')).layoutWeight(1).borderRadius(10).onClick((event) => {
          EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 5)
          router.back()
        })
        Blank().width(10)
        Image($r('app.media.dd')).layoutWeight(1).borderRadius(10).onClick((event) => {
          EmitterUtil.post<number>(Constants.Message_Editor_Wallpaper, 4)
          router.back()
        })
      }.height(80).padding({ left: 15, right: 15 }).margin({ top: 10 })


      Row() {
        Column() {
          Image($r('app.media.desktop')).width(20).height(20)
          Text($r('app.string.desktop')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          WantUtil.toWebBrowser("https://gitee.com/knowshub/only-write/releases/")
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.setting')).width(20).height(20)
          Text($r('app.string.likesetting')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          CommUtils.openPage("pages/setting/SettingPage", new PageBean("0", $r('app.string.privacy')))
        })

        Blank().width(10)
        Column() {
          Image($r('app.media.pravicy')).width(20).height(20)
          Text($r('app.string.privacy')).fontSize(12).margin({ top: 10 })
        }
        .padding(15)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .borderRadius(10)
        .layoutWeight(1)
        .onClick((event) => {
          CommUtils.openPage("pages/other/WebPage", new PageBean("0", $r('app.string.privacy')))
        })

      }.padding({ left: 15, right: 15 }).margin({ top: 10 })

      Blank()
      Text(this.versionName).textAlign(TextAlign.Center).fontSize(12).fontWeight(200)
    }.height('100%')
    .width('100%')

  }
}