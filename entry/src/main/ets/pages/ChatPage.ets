@Component
export struct ChatPage {
  @State messageList: ChatMessage[] = [
    { id: 1, content: '你好！我是校园智能助手，有什么可以帮助你的吗？', isUser: false, time: '09:00' },
    { id: 2, content: '今天有什么课程安排？', isUser: true, time: '09:01' },
    { id: 3, content: '今天上午8:00-9:40有高等数学课，教室在教一201', isUser: false, time: '09:01' }
  ];

  @State inputText: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('智能对话')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')

        Blank()

        Text('\ue67a')
          .fontSize(22)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#007DFF')
          .margin({ right: 8 })
          .onClick(() => {
            // 清空对话
            this.messageList = [];
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 消息列表
      Scroll() {
        Column() {
          ForEach(this.messageList, (item: ChatMessage) => {
            this.buildMessageItem(item)
          }, (item: ChatMessage) => item.id.toString())
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 12, bottom: 80 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)

      // 输入区域
      this.buildInputArea()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
  }

  @Builder
  buildMessageItem(item: ChatMessage) {
    Column() {
      if (item.isUser) {
        // 用户消息（右侧）
        Row() {
          Blank()

          Column() {
            Text(item.content)
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
              .maxLines(10)

            Text(item.time)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4, right: 8 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ top: 8 })
        }
        .width('100%')
      } else {
        // 助手消息（左侧）
        Row() {
          Column() {
            // 助手标识
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

            Text(item.content)
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

            Text(item.time)
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
  }

  @Builder
  buildInputArea() {
    Column() {
      Row() {
        // 扩展功能按钮
        Text('\ue65c')
          .fontSize(24)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#666666')
          .margin({ left: 12, right: 8 })
          .onClick(() => {
            // 打开扩展功能
          })

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
        if (this.inputText.length > 0) {
          Text('\ue6b8')
            .fontSize(24)
            .fontFamily('HarmonyOS_Sans')
            .fontColor('#007DFF')
            .margin({ left: 8, right: 12 })
            .onClick(() => {
              this.sendMessage();
            })
        } else {
          Text('\ue65f')
            .fontSize(24)
            .fontFamily('HarmonyOS_Sans')
            .fontColor('#666666')
            .margin({ left: 8, right: 12 })
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#F0F2F5')
      .borderRadius({ topLeft: 20, topRight: 20 })
    }
    .width('100%')
    .position({ x: 0, y: '100%' })
    .translate({ y: -56 })
  }

  // 发送消息
  sendMessage() {
    if (this.inputText.trim() === '') return;

    const newMessage: ChatMessage = {
      id: this.messageList.length + 1,
      content: this.inputText,
      isUser: true,
      time: this.getCurrentTime()
    };

    this.messageList = [...this.messageList, newMessage];
    this.inputText = '';

    // 模拟AI回复
    setTimeout(() => {
      const aiResponse: ChatMessage = {
        id: this.messageList.length + 1,
        content: this.getAIResponse(newMessage.content),
        isUser: false,
        time: this.getCurrentTime()
      };
      this.messageList = [...this.messageList, aiResponse];
    }, 1000);
  }

  // 模拟AI回复
  getAIResponse(userMessage: string): string {
    if (userMessage.includes('课程') || userMessage.includes('课表')) {
      return '今天上午8:00-9:40有高等数学课，教室在教一201；10:00-11:40有大学英语课，教室在教二305。';
    } else if (userMessage.includes('成绩') || userMessage.includes('考试')) {
      return '您的上学期成绩已全部公布，平均绩点为3.6。详细成绩可在"应用-成绩查询"中查看。';
    } else if (userMessage.includes('图书馆') || userMessage.includes('借书')) {
      return '图书馆开放时间为8:00-22:00。您目前有两本图书即将到期，请在"应用-图书馆"中查看详情。';
    } else {
      return '已收到您的消息。我是校园智能助手，可以帮您查询课程、成绩、图书馆信息等。请告诉我您需要什么帮助？';
    }
  }

  // 获取当前时间
  getCurrentTime(): string {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
}

// 消息数据模型
interface ChatMessage {
  id: number;
  content: string;
  isUser: boolean;
  time: string;
}