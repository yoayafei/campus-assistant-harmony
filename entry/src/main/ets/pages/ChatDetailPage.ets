// entry/src/main/ets/pages/ChatDetailPage.ets
import { ChatMessage, ChatDataService } from '../model/ChatModels';
import router from '@ohos.router';

@Entry
@Component
export struct ChatDetailPage {
  @State messageList: ChatMessage[] = [];
  @State inputText: string = '';
  @State currentSessionId: string = '';
  @State sessionTitle: string = '';

  aboutToAppear() {
    // 从路由参数获取sessionId
    const params = router.getParams() as Record<string, string>;
    if (params && params['sessionId']) {
      this.currentSessionId = params['sessionId'];
      this.loadMessages();
    }
  }

  loadMessages() {
    this.messageList = ChatDataService.getMessagesBySessionId(this.currentSessionId);
    this.sessionTitle = this.getMessageSessionTitle();
  }

  build() {
    Column() {
      // 顶部标题栏（带返回按钮）
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.back_icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor('#00000000')
        .onClick(() => {
          router.back();
        })

        Text(this.sessionTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ left: 8 })

        Blank()

        // 更多操作菜单
        Button({ type: ButtonType.Normal }) {
          Text('\ue5d4')
            .fontSize(20)
            .fontFamily('HarmonyOS_Sans')
            .fontColor('#666666')
        }
        .width(40)
        .height(40)
        .backgroundColor('#00000000')
        .onClick(() => {
          this.showMoreActions();
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 消息列表
      Scroll() {
        Column() {
          ForEach(this.messageList, (message: ChatMessage) => {
            this.buildMessageItem(message)
          }, (message: ChatMessage) => message.id)
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 80 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      // 输入区域（复用你之前的设计，稍作调整）
      Column() {
        Row() {
          // 扩展功能按钮
          Button({ type: ButtonType.Normal }) {
            Text('\ue65c')
              .fontSize(24)
              .fontFamily('HarmonyOS_Sans')
              .fontColor('#666666')
          }
          .width(40)
          .height(40)
          .backgroundColor('#00000000')
          .margin({ left: 8 })

          // 输入框
          TextInput({ placeholder: '输入消息...', text: this.inputText })
            .width('100%')
            .height(40)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .fontSize(16)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.inputText = value;
            })
            .onSubmit(() => {
              this.sendMessage();
            })

          // 发送按钮
          Button({ type: ButtonType.Normal }) {
            Text(this.inputText.length > 0 ? '\ue6b8' : '\ue65f')
              .fontSize(24)
              .fontFamily('HarmonyOS_Sans')
              .fontColor(this.inputText.length > 0 ? '#007DFF' : '#666666')
          }
          .width(40)
          .height(40)
          .backgroundColor('#00000000')
          .margin({ right: 8 })
          .onClick(() => {
            if (this.inputText.length > 0) {
              this.sendMessage();
            }
          })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#F0F2F5')
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
  }

  @Builder
  buildMessageItem(message: ChatMessage) {
    Column() {
      if (message.isFromUser) {
        // 用户消息（右侧）
        Row() {
          Blank()

          Column() {
            Text(message.content)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#007DFF')
              .borderRadius({
                topLeft: 16,
                topRight: 4,
                bottomLeft: 16,
                bottomRight: 16
              })

            Text(this.formatMessageTime(message.timestamp))
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4, right: 8 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ top: 8 })
        }
        .width('100%')
      } else {
        // AI消息（左侧）
        Row() {
          Column() {
            // AI标识
            Row() {
              Text('AI')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor('#4CAF50')
                .borderRadius(10)

              Text('校园助手')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ left: 8 })
            }
            .margin({ bottom: 4 })

            Text(message.content)
              .fontSize(16)
              .fontColor('#000000')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#FFFFFF')
              .borderRadius({
                topLeft: 4,
                topRight: 16,
                bottomLeft: 16,
                bottomRight: 16
              })

            Text(this.formatMessageTime(message.timestamp))
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4, left: 8 })
          }
          .margin({ top: 8 })

          Blank()
        }
        .width('100%')
      }
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  // 发送消息
  sendMessage() {
    if (this.inputText.trim() === '') return;

    const newMessage: ChatMessage = {
      id: `${this.currentSessionId}_${Date.now()}`,
      sessionId: this.currentSessionId,
      content: this.inputText,
      isFromUser: true,
      timestamp: Date.now()
    };

    this.messageList = [...this.messageList, newMessage];
    this.inputText = '';

    // 模拟AI回复
    setTimeout(() => {
      const aiResponse: ChatMessage = {
        id: `${this.currentSessionId}_${Date.now()}_ai`,
        sessionId: this.currentSessionId,
        content: this.getAIResponse(newMessage.content),
        isFromUser: false,
        timestamp: Date.now()
      };
      this.messageList = [...this.messageList, aiResponse];
    }, 1000);
  }

  // 模拟AI回复（可以复用或优化）
  getAIResponse(userMessage: string): string {
    // 这里可以复用你之前的逻辑
    const responses = [
      "我明白了，这是一个关于校园生活的问题。",
      "让我帮你查找相关信息...",
      "根据我的理解，你问的是关于课程安排的事情对吗？",
      "这个问题很好，让我为你详细解答。",
      "我已经记录下你的问题，会尽快为你提供帮助。"
    ];

    return responses[Math.floor(Math.random() * responses.length)];
  }

  // 格式化消息时间
  formatMessageTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 获取会话标题
  getMessageSessionTitle(): string {
    // 这里可以根据sessionId获取实际标题
    const sessions = ChatDataService.getSessions();
    const session = sessions.find(s => s.id === this.currentSessionId);
    return session ? session.title : '对话详情';
  }

  // 显示更多操作
  showMoreActions() {
    // 这里可以显示操作菜单，如清空对话、导出记录等
    console.log('显示更多操作');
  }
}