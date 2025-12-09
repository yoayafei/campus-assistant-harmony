// entry/src/main/ets/pages/ConversationListPage.ets
import { ChatSession, ChatDataService } from '../model/ChatModels';
import router from '@ohos.router'

@Entry
@Component
export struct ConversationListPage {
  @State sessionList: ChatSession[] = [];
  @State searchText: string = '';

  aboutToAppear() {
    this.loadSessions();
  }

  loadSessions() {
    // 获取会话数据，按置顶和时间排序
    const sessions = ChatDataService.getSessions();
    this.sessionList = sessions.sort((a, b) => {
      // 先按置顶排序
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // 再按时间倒序
      return b.timestamp - a.timestamp;
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('对话')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')

        Blank()

        // 新建会话按钮（豆包风格的"+"按钮）
        Button({ type: ButtonType.Normal }) {
          Text('+')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .backgroundColor('#007DFF')
        .borderRadius(20)
        .onClick(() => {
          this.createNewSession();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 搜索框
      Row() {
        Text('\ue67c')
          .fontSize(18)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#999999')
          .margin({ left: 12, right: 8 })

        TextInput({ placeholder: '搜索对话...', text: this.searchText })
          .width('100%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .fontSize(16)
          .onChange((value: string) => {
            this.searchText = value;
            this.filterSessions(value);
          })
      }
      .width('100%')
      .height(48)
      .margin({ top: 8, left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })

      // 会话列表
      if (this.sessionList.length > 0) {
        List({ space: 0 }) {
          ForEach(this.sessionList, (session: ChatSession) => {
            ListItem() {
              this.buildSessionItem(session)
            }
            .onClick(() => {
              this.navigateToChatDetail(session.id);
            })
          }, (session: ChatSession) => session.id)
        }
        .width('100%')
        .margin({ top: 8 })
        .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 72, endMargin: 16 })
      } else {
        // 空状态提示
        Column() {
          Image($r('app.media.empty_conversation'))
            .width(120)
            .height(120)
            .margin({ bottom: 20 })

          Text('还没有对话')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })

          Text('点击右上角"+"开始新的对话')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height('70%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F6F6')
  }

  @Builder
  buildSessionItem(session: ChatSession) {
    Row() {
      // 会话头像
      Column() {
        Text(session.avatar)
          .fontSize(20)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor(this.getAvatarColor(session.id))
      .borderRadius(24)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 16, right: 12 })

      // 会话信息
      Column() {
        Row() {
          // 会话标题
          Text(session.title)
            .fontSize(16)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Blank()

          // 时间
          Text(this.formatTime(session.timestamp))
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          // 消息预览
          Text(session.preview)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .flexShrink(1)

          Blank()

          // 未读消息计数
          if (session.unreadCount > 0) {
            Text(session.unreadCount.toString())
              .fontSize(12)
              .fontColor('#FFFFFF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#FF3B30')
              .borderRadius(10)
          }

          // 置顶标识
          if (session.isPinned) {
            Text('\ue61e')
              .fontSize(14)
              .fontFamily('HarmonyOS_Sans')
              .fontColor('#FF9500')
              .margin({ left: 8 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height(48)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(72)
    .padding({ right: 16 })
    .backgroundColor('#FFFFFF')
  }

  // 创建新会话
  createNewSession() {
    const newSession = ChatDataService.createNewSession();
    // 先添加到列表
    this.sessionList = [newSession, ...this.sessionList];
    // 跳转到新会话的详情页
    this.navigateToChatDetail(newSession.id);
  }

  // 跳转到对话详情页
  navigateToChatDetail(sessionId: string) {
    // 使用router跳转，传递sessionId参数
    router.pushUrl({
      url: 'pages/ChatDetailPage',
      params: { sessionId: sessionId }
    });
  }

  // 过滤会话
  filterSessions(keyword: string) {
    const allSessions = ChatDataService.getSessions();
    if (!keyword.trim()) {
      this.loadSessions();
      return;
    }

    this.sessionList = allSessions.filter(session =>
    session.title.includes(keyword) ||
    session.preview.includes(keyword)
    ).sort((a, b) => {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp - a.timestamp;
    });
  }

  // 辅助方法：格式化时间显示
  formatTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    const date = new Date(timestamp);

    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
    if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`;

    return `${date.getMonth() + 1}/${date.getDate()}`;
  }

  // 辅助方法：根据ID生成头像颜色
  getAvatarColor(id: string): string {
    const colors = ['#4CAF50', '#2196F3', '#FF9800', '#9C27B0', '#F44336'];
    const index = parseInt(id) % colors.length;
    return colors[index] || '#007DFF';
  }
}