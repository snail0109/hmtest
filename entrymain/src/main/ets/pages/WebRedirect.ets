
import router from '@ohos.router';
import web_webview from '@ohos.web.webview';
@Entry
@Component
struct WebRedirect {
  @State url: string = ''
  webController: web_webview.WebviewController = new web_webview.WebviewController();
  aboutToAppear() {
    const params = router.getParams() as Record<string, Object> | undefined
    const u = params && typeof params['url'] === 'string' ? params['url'] as string : ''
    this.url = u
  }

  build() {
    Column() {
      if (this.url) {
        Web({ src: this.url, controller: this.webController })
          .width('100%')
          .height('100%')
      } else {
        Text('无效的跳转地址')
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
