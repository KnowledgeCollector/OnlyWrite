import { TitleBar } from '../../widget/TitleBar';
import { CommUtils } from '../../utils/CommUtils';
import { PageBean } from '../../bean/PageBean';
import { PreferencesUtil, ToastUtil } from '@pura/harmony-utils';
import { AliyunUtils } from '../../model/cloud/aliyun/AliyunUtils';
import { BaiduyunUtils } from '../../model/cloud/baiduyun/BaiduyunUtils';


@Entry
@Component
struct CloudPage {
  //阿里
  @State isAliyunOpen: boolean = false
  @State aliyunFolder: string = '只是写作'
  //百度
  @State isBaiduOpen: boolean = false
  @State baiduFolder: string = '只是写作'

  aboutToAppear(): void {
    this.isAliyunOpen = PreferencesUtil.getBooleanSync("aliyunpan_backup");
    this.isBaiduOpen = PreferencesUtil.getBooleanSync("baiduyun_backup");
  }

  onPageShow(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, string>; // 获取传递过来的参数对象
    if (params) {
      if (params.aliyunCode) {
        let aliyunCode: string = params.aliyunCode as string
        this.initAliyunAuth(aliyunCode)
      } else if (params.baiduToken) {
        let baiduToken = params.baiduToken
        this.initBaiduAuth(baiduToken)
      }
    }
  }

  build() {
    Column() {
      TitleBar({ title: $r('app.string.data_manager') })
      Column() {
        Column() {
          Text($r('app.string.aliyun_backup')).fontSize(16).fontColor($r('sys.color.ohos_id_text_color_active'))
          Text(this.aliyunFolder).fontSize(13).fontColor(Color.Grey).margin({ top: 5 })
          Row() {
            Column() {
              Text($r('app.string.cloud_backup')).fontSize(16)
              Text($r('app.string.cloud_backup_tip'))
                .fontSize(13)
                .fontColor(Color.Grey)
                .margin({ top: 5, right: 10 })
            }.layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)

            Stack() {
              Toggle({ type: ToggleType.Switch, isOn: this.isAliyunOpen }).height(30).width(50)
              Text().height(30).width(50).onClick((event) => {
                if (this.isAliyunOpen) {
                  this.isAliyunOpen = false
                  PreferencesUtil.putSync("aliyunpan_backup", false);
                } else {
                  this.openAliyunCloud()
                }
              })
            }
          }.margin({ top: 10 }).alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .borderRadius(10)
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)

        Blank().height(15)

        Column() {
          Text($r('app.string.baidu_backup')).fontSize(16).fontColor($r('sys.color.ohos_id_text_color_active'))
          Text(this.aliyunFolder).fontSize(13).fontColor(Color.Grey).margin({ top: 5 })
          Row() {
            Column() {
              Text($r('app.string.cloud_backup')).fontSize(16)
              Text($r('app.string.cloud_backup_tip'))
                .fontSize(13)
                .fontColor(Color.Grey)
                .margin({ top: 5, right: 10 })
            }.layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)

            Stack() {
              Toggle({ type: ToggleType.Switch, isOn: this.isBaiduOpen }).height(30).width(50)
              Text().height(30).width(50).onClick((event) => {
                if (this.isBaiduOpen) {
                  this.isBaiduOpen = false
                  PreferencesUtil.putSync("baiduyun_backup", false);
                } else {
                  this.openBaiduyunCloud()
                }
              })
            }
          }.margin({ top: 10 }).alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .borderRadius(10)
        .padding(15)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
      }
      .padding({ left: 15, right: 15, top: 15 })
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }.height('100%')
    .width('100%')
  }

  openAliyunCloud() {
    PreferencesUtil.putSync("aliyunpan_folder", this.aliyunFolder)
    let url = "https://openapi.alipan.com/oauth/authorize?client_id=换成你自己的&redirect_uri=now://com.start.aliyunpan&scope=user:base,file:all:read,file:all:write&code_challenge=$random&code_challenge_method=plain"
    CommUtils.openPage("pages/other/WebPage",
      new PageBean("pages/setting/CloudPage", $r('app.string.aliyun_backup'), url))
  }

  initAliyunAuth(authCode: string) {
    AliyunUtils.getInstance().aliyunpan_getToken(authCode).then((token) => {
      if (token) {
        PreferencesUtil.putSync("aliyunpan_token", token['access_token']);
        PreferencesUtil.putSync("aliyunpan_refreshtoken", token['refresh_token']);
        PreferencesUtil.putSync("aliyunpan_expires_in", token['expires_in']);
        PreferencesUtil.putSync("aliyunpan_token_time", Date.now());
        AliyunUtils.getInstance().aliyunpan_getDriveInfo().then((drive) => {
          if (drive) {
            let backup_drive_id: string = drive["backup_drive_id"];
            PreferencesUtil.putSync("aliyunpan_driveid", backup_drive_id);
            AliyunUtils.getInstance().aliyunpan_initPath((ok: boolean) => {
              if (ok) {
                this.isAliyunOpen = true
                this.isBaiduOpen = false
                PreferencesUtil.putSync("aliyunpan_backup", true);
                PreferencesUtil.putSync("baiduyun_backup", false);
              } else {
                ToastUtil.showToast($r('app.string.init_cloud_fail'))
              }
            })
          }
        })
      }
    })
  }

  openBaiduyunCloud() {
    let url = "http://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=换成你自己的&redirect_uri=oob&scope=basic,netdisk&display=mobile"
    CommUtils.openPage("pages/other/WebPage",
      new PageBean("pages/setting/CloudPage", $r('app.string.baidu_backup'), url))
  }

  initBaiduAuth(accessToken: string) {
    PreferencesUtil.putSync("baiduyun_folder", this.baiduFolder)
    PreferencesUtil.putSync("baiduyun_token", accessToken)
    BaiduyunUtils.getInstance().baidupan_createFolder("html").then((ok) => {
      if (ok) {
        this.isAliyunOpen = false
        this.isBaiduOpen = true
        PreferencesUtil.putSync("aliyunpan_backup", false);
        PreferencesUtil.putSync("baiduyun_backup", true);
      } else {
        ToastUtil.showToast($r('app.string.init_cloud_fail'))
      }
    })
  }
}