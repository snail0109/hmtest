import http from '@ohos.net.http';
import router from '@ohos.router';

interface LoginResponse {
  errno?: number;
  errmsg?: string
}

interface CheckLoginResp {
  errno?: number;
  errmsg?: string;
  code?: string;
  auth_url?: string
}

function rhex(n: number): string {
  let s = "", j: number;
  for (j = 0; j < 4; j++) {
    s += ("0" + ((n >> (j * 8 + 4)) & 0x0F).toString(16)).slice(-1) +
    ("0" + ((n >> (j * 8)) & 0x0F).toString(16)).slice(-1);
  }
  return s
}

function add(x: number, y: number): number {
  return ((x & 0xFFFF) + (y & 0xFFFF)) + (((x >>> 16) + (y >>> 16)) << 16)
}

function rol(n: number, c: number): number {
  return (n << c) | (n >>> (32 - c))
}

function cmn(q: number, a: number, b: number, x: number, s: number, t: number): number {
  return add(rol(add(add(a, q), add(x, t)), s), b)
}

function ff(a: number, b: number, c: number, d: number, x: number, s: number, t: number): number {
  return cmn((b & c) | ((~b) & d), a, b, x, s, t)
}

function gg(a: number, b: number, c: number, d: number, x: number, s: number, t: number): number {
  return cmn((b & d) | (c & (~d)), a, b, x, s, t)
}

function hh(a: number, b: number, c: number, d: number, x: number, s: number, t: number): number {
  return cmn(b ^ c ^ d, a, b, x, s, t)
}

function ii(a: number, b: number, c: number, d: number, x: number, s: number, t: number): number {
  return cmn(c ^ (b | (~d)), a, b, x, s, t)
}

function str2blksMD5(s: string): number[] {
  let nblk = ((s.length + 8) >> 6) + 1, blks: number[] = new Array(nblk * 16);
  let i: number;
  for (i = 0; i < nblk * 16; i++) {
    blks[i] = 0;
  }
  for (i = 0; i < s.length; i++) {
    blks[i >> 2] |= s.charCodeAt(i) << ((i % 4) * 8);
  }
  blks[i >> 2] |= 0x80 << ((i % 4) * 8);
  blks[nblk * 16 - 2] = s.length * 8;
  return blks
}

function md5hex(str: string): string {
  let x = str2blksMD5(str), a = 1732584193, b = -271733879, c = -1732584194, d = 271733878;
  for (let i = 0; i < x.length; i += 16) {
    let olda = a, oldb = b, oldc = c, oldd = d;
    a = ff(a, b, c, d, x[i + 0], 7, -680876936);
    d = ff(d, a, b, c, x[i + 1], 12, -389564586);
    c = ff(c, d, a, b, x[i + 2], 17, 606105819);
    b = ff(b, c, d, a, x[i + 3], 22, -1044525330);
    a = ff(a, b, c, d, x[i + 4], 7, -176418897);
    d = ff(d, a, b, c, x[i + 5], 12, 1200080426);
    c = ff(c, d, a, b, x[i + 6], 17, -1473231341);
    b = ff(b, c, d, a, x[i + 7], 22, -45705983);
    a = ff(a, b, c, d, x[i + 8], 7, 1770035416);
    d = ff(d, a, b, c, x[i + 9], 12, -1958414417);
    c = ff(c, d, a, b, x[i + 10], 17, -42063);
    b = ff(b, c, d, a, x[i + 11], 22, -1990404162);
    a = ff(a, b, c, d, x[i + 12], 7, 1804603682);
    d = ff(d, a, b, c, x[i + 13], 12, -40341101);
    c = ff(c, d, a, b, x[i + 14], 17, -1502002290);
    b = ff(b, c, d, a, x[i + 15], 22, 1236535329);
    a = gg(a, b, c, d, x[i + 1], 5, -165796510);
    d = gg(d, a, b, c, x[i + 6], 9, -1069501632);
    c = gg(c, d, a, b, x[i + 11], 14, 643717713);
    b = gg(b, c, d, a, x[i + 0], 20, -373897302);
    a = gg(a, b, c, d, x[i + 5], 5, -701558691);
    d = gg(d, a, b, c, x[i + 10], 9, 38016083);
    c = gg(c, d, a, b, x[i + 15], 14, -660478335);
    b = gg(b, c, d, a, x[i + 4], 20, -405537848);
    a = gg(a, b, c, d, x[i + 9], 5, 568446438);
    d = gg(d, a, b, c, x[i + 14], 9, -1019803690);
    c = gg(c, d, a, b, x[i + 3], 14, -187363961);
    b = gg(b, c, d, a, x[i + 8], 20, 1163531501);
    a = gg(a, b, c, d, x[i + 13], 5, -1444681467);
    d = gg(d, a, b, c, x[i + 2], 9, -51403784);
    c = gg(c, d, a, b, x[i + 7], 14, 1735328473);
    b = gg(b, c, d, a, x[i + 12], 20, -1926607734);
    a = hh(a, b, c, d, x[i + 5], 4, -378558);
    d = hh(d, a, b, c, x[i + 8], 11, -2022574463);
    c = hh(c, d, a, b, x[i + 11], 16, 1839030562);
    b = hh(b, c, d, a, x[i + 14], 23, -35309556);
    a = hh(a, b, c, d, x[i + 1], 4, -1530992060);
    d = hh(d, a, b, c, x[i + 4], 11, 1272893353);
    c = hh(c, d, a, b, x[i + 7], 16, -155497632);
    b = hh(b, c, d, a, x[i + 10], 23, -1094730640);
    a = ii(a, b, c, d, x[i + 0], 6, 681279174);
    d = ii(d, a, b, c, x[i + 7], 10, -358537222);
    c = ii(c, d, a, b, x[i + 14], 15, -722521979);
    b = ii(b, c, d, a, x[i + 5], 21, 76029189);
    a = ii(a, b, c, d, x[i + 12], 6, -640364487);
    d = ii(d, a, b, c, x[i + 3], 10, -421815835);
    c = ii(c, d, a, b, x[i + 10], 15, 530742520);
    b = ii(b, c, d, a, x[i + 1], 21, -995338651);
    a = add(a, olda);
    b = add(b, oldb);
    c = add(c, oldc);
    d = add(d, oldd)
  }
  return rhex(a) + rhex(b) + rhex(c) + rhex(d)
}

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State message: string = ''
  @State loginCodeText: string = ''
  private timerId: number = 0
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


      Text('密码')
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)
      Row() {
        TextInput({ placeholder: '请输入密码' })
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
        Button('获取动态码')
          .enabled(this.timerId === 0)
          .margin({ left: 20, top: 16 })
          .onClick(() => {
            this.getDynamicCode()
          })
        if (this.loginCodeText) {
          Text(this.loginCodeText)
            .margin({ top: 16 })
        }
      }

      Row() {
        if (this.message) {
          Text(this.message)
        }
      }
    }.width('40%')
    .height('50%')
    .padding(24)
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
    console.log(`get_login_code_robot(user_id=${encodeURIComponent(u)}&key=${encodeURIComponent(this.WebKey)}&from=im_h5)`)
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
      console.log("调用get_login_code_robot成功")
      let ok = false
      try {
        this.message = (res.result ?? '').toString()
        let ct = 60
        this.loginCodeText = `${ct}s后重新发送`
        this.timerId = setInterval(() => {
          ct -= 1
          if (ct <= 0) {
            this.loginCodeText = '获取动态码'
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
      this.message = '获取令牌失败'
      this.loginCodeText = '获取动态码'
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
      this.message = '密码/安全令牌不能为空'
      return
    }
    const md5pwd = `{md5}${md5hex(p)}{md5}`
    const body = `username=${encodeURIComponent(u)}&edt_md5_pwd=${encodeURIComponent(md5pwd)}`
    const client = http.createHttp()
    client.request(this.WebRootUrl + '/login/v2/auth/check_login', {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      extraData: body,
      readTimeout: 3000,
      connectTimeout: 3000
    }).then((res) => {
      let ok = false
      let code = ''
      let errmsg = ''
      let authUrl = ''
      try {
        const data: CheckLoginResp = JSON.parse((res.result ?? '').toString()) as CheckLoginResp
        if (data && data.errno === 0) {
          ok = true
          code = data.code ?? ''
        } else {
          errmsg = data?.errmsg ?? `登录失败 (${data?.errno ?? res.responseCode})`
          authUrl = data?.auth_url ?? ''
        }
      } catch (_e) {
      }
      if (ok) {
        if (!this.WebRootUrl) {
          this.message = '跳转地址未配置'
          return
        }
        const url = this.composeRedirectUrl(this.WebRootUrl, code)
        router.pushUrl({ url: 'pages/WebRedirect', params: { url } })
      } else {
        const msg = errmsg ? (authUrl ? `${errmsg} (${authUrl})` : errmsg) : '登录失败，请使用钉钉扫码登录！(90000)'
        this.message = msg
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

  private composeRedirectUrl(base: string, code: string): string {
    let url = base
    const hasHttp = url.toLowerCase().indexOf('http') === 0
    if (hasHttp) {
      if (url.indexOf('{code}') >= 0) {
        url = url.replace(/\{code\}/g, code)
      } else {
        url = url + (url.indexOf('?') < 0 ? `?code=${code}` : `&code=${code}`)
      }
    }
    url = url + (url.indexOf('?') < 0 ? `?language=zh_CN` : `&language=zh_CN`)
    return url
  }
}
