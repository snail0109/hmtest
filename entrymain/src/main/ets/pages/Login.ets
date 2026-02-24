import http from '@ohos.net.http';
import router from '@ohos.router';

interface CheckLoginResp {
  code?: number;
  message?: string;
  where?: string;
}
interface ResultLoginResp {
  id?: string;
  code?: number;
  name?: string;
  mail?: string;
  phone?: string;
  dept?: string;
  org?: string;
  job?: string;
  belong?: string;
  station?: string;
  dept_id?: number;
  org_id?: number;
  job_id?: number;
}
@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State message: string = ''
  @State loginCodeText: string = ''
  @State enableCodeButton: boolean = true
  private timerId: number = 0
  private countdown: number = 60
  private WebRootUrl: string = ''
  private WebKey: string = ''

  aboutToAppear() {
    try {
      const rm = getContext(this).resourceManager
      rm.getRawFile('app_config.json').then((data: Uint8Array | ArrayBuffer) => {
        let bytes: Uint8Array
        if (data instanceof Uint8Array) {
          bytes = data
        } else {
          bytes = new Uint8Array(data as ArrayBuffer)
        }
        let text = ''
        for (let i = 0; i < bytes.length; i++) {
          text += String.fromCharCode(bytes[i])
        }
        const cfg = JSON.parse(text) as Record<string, string>
        const url = typeof cfg['WebRootUrl'] === 'string' ? cfg['WebRootUrl'] as string : ''
        if (url) {
          this.WebRootUrl = url
        }
        const code = typeof cfg['DefaultLoginCode'] === 'string' ? cfg['DefaultLoginCode'] as string : ''
        if (code) {
          this.username = code
        }
        const key = typeof cfg['WebKey'] === 'string' ? cfg['WebKey'] as string : ''
        if (key) {
          this.WebKey = key
        }
      }).catch(() => {
      })
    } catch {
    }
  }

  build(): void {
    Column() {
      Text('统一登录中心')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })


      Text('用户名')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: '请输入用户名', text: this.username })
        .onChange((value: string) => {
          this.username = value
        })
        .margin({ bottom: 16 })


      Text('动态口令')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)
      Row() {
        TextInput({ placeholder: '请动态口令', text: '734239' })
          .onChange((value: string) => {
            this.password = value
          })
          .layoutWeight(1)
          .margin({ right: 12 })

      }.alignItems(VerticalAlign.Center)


      Row() {
        Button('登录')
          .onClick(() => this.login())
          .margin({ top: 16 })
          .alignSelf(ItemAlign.Start)
        Button('获取动态口令')
          .enabled(this.enableCodeButton)
          .margin({ left: 20, top: 16 })
          .onClick(() => {
            this.getDynamicCode()
          })
        if (this.loginCodeText) {
          Text(this.loginCodeText)
            .margin({ left:20,top: 16 })
        }
      }

      Row() {
        if (this.message) {
          Text(this.message)
            .margin({ top: 16 })
        }
      }

      // SSH登录按钮
      Button('SSH远程登录')
        .width('100%')
        .height(45)
        .backgroundColor('#1890ff')
        .fontColor('#ffffff')
        .margin({ top: 30 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SSHLogin'
          })
        })
    }.width('50%')
    .height('50%')
    .padding(40)
    .margin({ left: 'auto', right: 'auto' })
  }

  private getDynamicCode(): void {
    const u = this.username.trim()
    if (!u) {
      this.message = '工号不能为空'
      return
    }
    if (this.timerId > 0) {
      return
    }
    this.message = ''
    this.loginCodeText = ''
    const client = http.createHttp()
    client.request(this.WebRootUrl + '/auth_157/get_login_code_robot', {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      extraData: `user_id=${encodeURIComponent(u)}&key=${encodeURIComponent(this.WebKey)}&from=im_h5`,
      readTimeout: 3000,
      connectTimeout: 3000
    }).then((res) => {
      console.log("调用get_login_code_robot成功", (res.result ?? '').toString())
      try {
        this.message = (res.result ?? '').toString()
        this.enableCodeButton = false
        let ct = this.countdown
        this.loginCodeText = `${ct}s后重新发送`
        this.timerId = setInterval(() => {
          ct -= 1
          if (ct <= 50) {
            this.enableCodeButton = true
          }
          if (ct <= 0) {
            this.loginCodeText = ''
            this.enableCodeButton = true
            clearInterval(this.timerId)
            this.timerId = 0
          } else {
            this.loginCodeText = `${ct}s后重新发送`
          }
        }, 1000)
      } catch (error) {
        console.error("处理响应数据时出错:", error)
      }
    }).catch((_err: Error) => {
      this.message = '获取动态口令失败'
      this.loginCodeText = ''
    }).finally(() => {
      try {
        client.destroy()
      } catch {
      }
    })
  }

  private login(): void {
    const u = this.username.trim()
    const p = this.password.trim()
    if (!u) {
      this.message = '工号不能为空'
      return
    }
    if (!p) {
      this.message = '动态口令不能为空'
      return
    }
    const body = `${encodeURIComponent(this.WebKey)}&staff_code=${u}&pass_word=${p}`
    const client = http.createHttp()
    client.request(this.WebRootUrl + '/auth_157/login_code', {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      extraData: body,
      readTimeout: 3000,
      connectTimeout: 3000
    }).then((res) => {
      console.log(res.responseCode.toString(), "调用login_code成功", (res.result ?? '').toString())
      try {
        if (res.responseCode === 200) {
          const data: ResultLoginResp = JSON.parse((res.result ?? '').toString()) as ResultLoginResp
          this.message = `${data.org ?? ''} - ${data.name ?? ''} (${data.job ?? ''})`
        } else {
          const data: CheckLoginResp = JSON.parse((res.result ?? '').toString()) as CheckLoginResp
          if (data && data.code === 0) {
            this.message = "登录成功"
          } else {
            this.message = data.message ?? ''
          }
        }
      } catch (error) {
        console.error("处理响应数据时出错:", error)
      }
    }).catch((_err: Error) => {
      this.message = '登录失败，请使用钉钉扫码登录！(90000)'
    }).finally(() => {
      try {
        client.destroy()
      } catch {
      }
    })
  }
}
