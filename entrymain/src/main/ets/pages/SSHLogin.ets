@Entry
@Component
struct SSHLogin {
  @State host: string = ''
  @State port: string = '22'
  @State username: string = ''
  @State password: string = ''
  @State isConnecting: boolean = false
  @State connectionStatus: string = '未连接'
  @State terminalContent: string = ''
  @State showTerminal: boolean = false

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('SSH远程登录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank()
        Text(this.connectionStatus)
          .fontSize(14)
          .fontColor(this.connectionStatus === '已连接' ? '#52c41a' : '#ff4d4f')
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .backgroundColor('#f5f5f5')

      // 连接配置表单
      if (!this.showTerminal) {
        Column() {
          // 主机地址
          Row() {
            Text('主机地址:')
              .fontSize(16)
              .width('30%')
            TextInput({ text: this.host })
              .placeholder('请输入主机IP或域名')
              .width('70%')
              .onChange((value: string) => {
                this.host = value
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })

          // 端口
          Row() {
            Text('端口:')
              .fontSize(16)
              .width('30%')
            TextInput({ text: this.port })
              .placeholder('默认22')
              .width('70%')
              .onChange((value: string) => {
                this.port = value
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })

          // 用户名
          Row() {
            Text('用户名:')
              .fontSize(16)
              .width('30%')
            TextInput({ text: this.username })
              .placeholder('请输入用户名')
              .width('70%')
              .onChange((value: string) => {
                this.username = value
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })

          // 密码
          Row() {
            Text('密码:')
              .fontSize(16)
              .width('30%')
            TextInput({ text: this.password })
              .placeholder('请输入密码')
              .type(InputType.Password)
              .width('70%')
              .onChange((value: string) => {
                this.password = value
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })

          // 连接按钮
          Button(this.isConnecting ? '连接中...' : '连接')
            .width('80%')
            .height(50)
            .backgroundColor(this.isConnecting ? '#d9d9d9' : '#1890ff')
            .fontColor('#ffffff')
            .fontSize(18)
            .margin({ top: 30 })
            .enabled(!this.isConnecting)
            .onClick(() => {
              this.connectSSH()
            })

          // 快速连接示例
          Text('快速连接示例:')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 40, bottom: 10 })
            .align(Alignment.Start)
            .width('100%')

          Row() {
            Button('本地测试')
              .height(35)
              .fontSize(12)
              .onClick(() => {
                this.host = '127.0.0.1'
                this.username = 'test'
              })
            Button('SSH服务器')
              .height(35)
              .fontSize(12)
              .margin({ left: 10 })
              .onClick(() => {
                this.host = '192.168.1.100'
                this.port = '22'
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#ffffff')
        .borderRadius(10)
        .shadow({ radius: 10, color: '#000000', offsetX: 2, offsetY: 2 })
        .margin({ top: 20 })
      }

      // 终端显示区域
      if (this.showTerminal) {
        Column() {
          // 终端控制栏
          Row() {
            Text('SSH终端')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Blank()
            Button('断开连接')
              .height(35)
              .fontSize(12)
              .onClick(() => {
                this.disconnectSSH()
              })
            Button('清屏')
              .height(35)
              .fontSize(12)
              .margin({ left: 10 })
              .onClick(() => {
                this.terminalContent = ''
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 10 })
          .backgroundColor('#1e1e1e')

          // 终端内容显示区域
          Scroll() {
            Text(this.terminalContent)
              .fontSize(14)
              .fontColor('#ffffff')
              .fontFamily('monospace')
              .textAlign(TextAlign.Start)
              .width('100%')
          }
          .width('100%')
          .height(400)
          .backgroundColor('#000000')
          .padding(10)

          // 终端输入区域
          Row() {
            TextInput({ text: '' })
              .placeholder('输入命令...')
              .width('80%')
              .backgroundColor('#2d2d2d')
              .fontColor('#ffffff')
              .onSubmit((value: string) => {
                this.sendCommand(value)
              })
            Button('发送')
              .width('20%')
              .height(40)
              .onClick(() => {
                // 发送命令逻辑
              })
          }
          .width('100%')
          .padding({ top: 10 })
        }
        .width('95%')
        .margin({ top: 20 })
        .border({ width: 1, color: '#333333' })
      }

      // 返回按钮
      Button('返回登录页')
        .width('80%')
        .height(45)
        .backgroundColor('#f0f0f0')
        .fontColor('#333333')
        .margin({ top: 30, bottom: 20 })
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fafafa')
    .padding({ left: 20, right: 20 })
  }

  // SSH连接方法
  private connectSSH(): void {
    if (!this.host || !this.username) {
      // TODO: 显示错误提示
      return
    }

    this.isConnecting = true
    this.connectionStatus = '连接中...'

    // 模拟SSH连接过程
    setTimeout(() => {
      this.isConnecting = false
      this.connectionStatus = '已连接'
      this.showTerminal = true
      this.terminalContent = `连接到 ${this.host}:${this.port} 成功\n欢迎使用SSH终端\n$ `
    }, 2000)
  }

  // 断开SSH连接
  private disconnectSSH(): void {
    this.showTerminal = false
    this.connectionStatus = '未连接'
    this.terminalContent = ''
    // TODO: 实现实际的断开连接逻辑
  }

  // 发送命令
  private sendCommand(command: string): void {
    if (!command.trim()) return

    // 添加命令到终端显示
    this.terminalContent += `${command}\n`
    
    // 模拟命令执行结果
    setTimeout(() => {
      this.terminalContent += `命令执行结果: ${command}\n$ `
    }, 500)
  }

  aboutToDisappear(): void {
    // 页面消失时断开连接
    this.disconnectSSH()
  }
}