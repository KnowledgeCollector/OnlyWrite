import web_webview from '@ohos.web.webview';
import { router } from '@kit.ArkUI';
import { PageBean } from '../../bean/PageBean';
import { TitleBar } from '../../widget/TitleBar';

@Entry
@Component
struct WebPage {
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  pageBean: PageBean = router.getParams() as PageBean
  @State url: string | Resource = ""

  aboutToAppear(): void {
    if (this.pageBean.fromPageUrl == "0") {
      this.url = $rawfile('pravicy.html')
    } else {
      this.url = this.pageBean.params as string
    }
  }

  build() {
    Column() {
      TitleBar({ title: this.pageBean.pageTitle })
      Web({ src: this.url, controller: this.controller })
        .imageAccess(true)
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onlineImageAccess(true)
        .mixedMode(MixedMode.All)
        .verticalScrollBarAccess(true)
        .width('100%')
        .height('100%')
        .onLoadIntercept((event) => {
          if (!event) {
            return;
          }
          let url = event.data.getRequestUrl()
          if (url.startsWith("now://com.start.aliyunpan")) {
            //阿里云授权码
            let authCode = url.substring(url.indexOf("?code=") + 6, url.length)
            router.back({
              url: this.pageBean.fromPageUrl,
              params: {
                aliyunCode: authCode
              }
            })
          }

          if (url.includes("https://openapi.baidu.com/oauth/2.0/login_success") && url.includes("access_token")) {
            //百度token
            let authCode = url.substring(
              url.indexOf("access_token=") + 13,
              url.indexOf("&session_secret")
            )
            router.back({
              url: this.pageBean.fromPageUrl,
              params: {
                baiduToken: authCode
              }
            })
          }
          return false;
        })

    }
  }
}