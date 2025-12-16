// pages/LibraryChatPage.ets (修复版)
import { ChatMessage, LibraryQueryRequest, LibraryAgentResponse, QuickAction, ChatMessageData } from '../model/Book';
import { LibraryService, sendChatQueryStream } from '../service/LibraryService';
import { Book } from '../model/Book';
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct LibraryChatPage {
  @State messages: ChatMessage[] = [
    {
      id: 1,
      role: 'assistant',
      content: '您好！我是校园图书馆智能助手。我可以帮您搜索图书、查询借阅状态、了解图书馆规则等。请问有什么可以帮助您的？',
      timestamp: new Date().toISOString(),
      type: 'WELCOME'
    }
  ];
  @State inputText: string = '';
  @State isLoading: boolean = false;

  private sessionId: number = Date.now();

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      const paramsObj = params as Record<string, string>; // 使用具体类型
      const initialQuery = paramsObj['initialQuery'];
      if (initialQuery && initialQuery.trim()) {
        this.inputText = initialQuery;
        this.sendMessage();
      }
    }
  }

  build() {
    Column() {
      // 快捷操作按钮
      Scroll() {
        Row({ space: 8 }) {
          this.buildQuickAction('搜索图书', 'search')
          this.buildQuickAction('借阅状态', 'status')
          this.buildQuickAction('开放时间', 'hours')
          this.buildQuickAction('热门推荐', 'popular')
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // 聊天消息列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.messages, (message: ChatMessage) => {
            this.buildMessageItem(message)
          })
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
      }
      .width('100%')
      .height('70%')
      .scrollBar(BarState.Off)

      // 输入区域
      Row() {
        TextInput({ placeholder: '请输入您的问题...', text: this.inputText })
          .width('80%')
          .height(40)
          .fontSize(14)
          .padding({ left: 12, right: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .onChange((value: string) => {
            this.inputText = value;
          })

        if (this.isLoading) {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#007DFF')
            .margin({ left: 12 })
        } else {
          Button('发送', { type: ButtonType.Normal })
            .fontSize(14)
            .backgroundColor('#007DFF')
            .borderRadius(20)
            .width(60)
            .height(40)
            .margin({ left: 12 })
            .onClick(() => {
              this.sendMessage();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildQuickAction(text: string, action: string) {
    Text(text)
      .fontSize(13)
      .fontColor('#007DFF')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#E6F2FF')
      .borderRadius(20)
      .onClick(() => {
        this.handleQuickAction(action);
      })
  }

  @Builder
  buildMessageItem(message: ChatMessage) {
    if (message.role === 'user') {
      // 用户消息
      Row() {
        Blank()
        Column() {
          Text(message.content)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#007DFF')
            .borderRadius(12)
            .width('70%')
        }
      }
      .width('100%')
      .padding({ right: 16 })
    } else {
      // 助手消息
      Row() {
        Column({ space: 12 }) {
          // 助手回复
          Column() {
            Text(message.content)
              .fontSize(14)
              .fontColor('#333333')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .width('70%')
          }

          // 建议文本 - 使用ArkUI的条件渲染
          if (message.suggestion) {
            Text(`💡 ${message.suggestion}`)
              .fontSize(12)
              .fontColor('#666666')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .width('70%')
          }

          // 快速操作按钮 - 使用ArkUI的条件渲染
          if (message.quickActions && message.quickActions.length > 0) {
            Row({ space: 8 }) {
              ForEach(message.quickActions, (action: QuickAction) => {
                Text(action.text)
                  .fontSize(12)
                  .fontColor('#007DFF')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor('#E6F2FF')
                  .borderRadius(15)
                  .onClick(() => {
                    this.handleQuickAction(action.action);
                  })
              })
            }
            .width('100%')
            .padding({ left: 8 })
          }

          // 图书推荐 - 使用ArkUI的条件渲染
          if (message.displayBooks && message.displayBooks.length > 0) {
            this.renderBookList(message.displayBooks)
          }
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .padding({ left: 16 })
    }
  }

  // 纯UI的 renderBookList 方法
  @Builder
  renderBookList(books: Book[]) {
    Column({ space: 8 }) {
      Text('📚 相关图书')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 4 })

      ForEach(books, (book: Book) => {
        this.renderBookItem(book)
      })
    }
    .width('100%')
    .padding({ left: 4 })
  }

  private shouldShowBooks(message: ChatMessage): boolean {
    if (!message.data) return false;
    if (message.type !== 'BOOK_SEARCH' && message.type !== 'BOOK_RECOMMENDATION') return false;

    const data = message.data as ChatMessageData;
    const books = data.books || data.recommendations || data.searchResults || data.popularBooks;
    return !!books && books.length > 0;
  }

  // 添加渲染书籍的方法
  @Builder
  renderBookItem(book: Book) {
    Row() {
      Column() {
        if (book.coverUrl && book.coverUrl.trim() !== '') {
          Image(book.coverUrl)
            .width(40)
            .height(50)
            .objectFit(ImageFit.Cover)
            .borderRadius(4)
        } else {
          Column() {
            Text(book.title?.charAt(0) || '书')
              .fontSize(12)
              .fontColor('#FFFFFF')
          }
          .width(40)
          .height(50)
          .backgroundColor('#007DFF')
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
        }
      }

      Column({ space: 2 }) {
        Text(book.title)
          .fontSize(12)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)

        Text(`作者: ${book.author}`)
          .fontSize(11)
          .fontColor('#666666')
          .maxLines(1)

        Row() {
          Text(`库存: ${book.availableCopies}/${book.totalCopies}`)
            .fontSize(10)
            .fontColor(book.availableCopies > 0 ? '#4CAF50' : '#F44336')

          Blank()

          Text('查看详情')
            .fontSize(10)
            .fontColor('#007DFF')
        }
        .width('100%')
        .margin({ top: 2 })
      }
      .margin({ left: 8 })
      .width('65%')
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .backgroundColor('#F8F8F8')
    .borderRadius(8)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/BookDetailPage',
        params: { bookId: book.id }
      });
    })
  }

  async sendMessage() {
    if (!this.inputText.trim()) return;

    const userMessage: ChatMessage = {
      id: Date.now(),
      role: 'user',
      content: this.inputText.trim(),
      timestamp: new Date().toISOString()
    };

    this.messages.push(userMessage);
    const queryText = this.inputText;
    this.inputText = '';
    this.isLoading = true;

    try {
      const request: LibraryQueryRequest = {
        query: queryText,
        sessionId: this.sessionId
      };

      // 创建一个空的助手消息
      const initialAssistantMessage: ChatMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: '', // 初始为空
        timestamp: new Date().toISOString(),
        type: 'TEXT',
        data: {},
        quickActions: [],
        needsFurtherHelp: false
      };

      // 添加到消息列表
      this.messages.push(initialAssistantMessage);
      const assistantMessageIndex = this.messages.length - 1;

      // 使用Promise包装SSE请求
      await new Promise<void>((resolve, reject) => {
        let fullResponse = '';

        sendChatQueryStream(request, {
          onContent: (content: string) => {
            fullResponse += content; // 累积内容
            // 创建新的消息数组以触发UI更新
            const newMessages: ChatMessage[] = [];
            for (let i = 0; i < this.messages.length; i++) {
              if (i === assistantMessageIndex) {
                // 手动复制对象属性，避免使用展开运算符
                const updatedMessage: ChatMessage = {
                  id: this.messages[i].id,
                  role: this.messages[i].role,
                  content: fullResponse,
                  timestamp: this.messages[i].timestamp,
                  type: this.messages[i].type,
                  data: this.messages[i].data,
                  suggestion: this.messages[i].suggestion,
                  quickActions: this.messages[i].quickActions,
                  needsFurtherHelp: this.messages[i].needsFurtherHelp,
                  displayBooks: this.messages[i].displayBooks
                };
                newMessages.push(updatedMessage);
              } else {
                newMessages.push(this.messages[i]);
              }
            }
            this.messages = newMessages;
          },
          onEnd: () => {
            resolve(); // 流结束时解决Promise
          },
          onError: (error: string) => {
            reject(new Error(error)); // 错误时拒绝Promise
          }
        });
      });

    } catch (error) {
      console.error('发送消息失败:', error);

      // 创建错误消息
      const errorMessage: ChatMessage = {
        id: Date.now() + 1,
        role: 'assistant',
        content: '抱歉，我遇到了问题。请稍后重试或联系图书馆管理员。',
        timestamp: new Date().toISOString(),
        type: 'ERROR'
      };

      // 替换最后一条消息（空的助手消息）为错误消息
      const newMessages: ChatMessage[] = [];
      for (let i = 0; i < this.messages.length; i++) {
        if (i === this.messages.length - 1) {
          newMessages.push(errorMessage);
        } else {
          newMessages.push(this.messages[i]);
        }
      }
      this.messages = newMessages;
    } finally {
      this.isLoading = false;
      this.scrollToBottom();
    }
  }

  async handleQuickAction(action: string) {
    let query = '';

    switch (action) {
      case 'search':
        query = '我想搜索图书';
        break;
      case 'status':
        query = '我的借阅状态是什么？';
        break;
      case 'hours':
        query = '图书馆什么时候开门？';
        break;
      case 'popular':
        query = '有什么热门图书推荐吗？';
        break;
      case 'view_popular_books':
        query = '看看热门图书';
        break;
      case 'view_borrow_records':
        query = '查看我的借阅记录';
        break;
      case 'view_library_rules':
        query = '图书馆有什么规则？';
        break;
      case 'view_library_hours':
        query = '图书馆开放时间是什么？';
        break;
      case 'borrow_popular_books':
        query = '推荐一些可以借阅的热门图书';
        break;
      default:
        query = action;
    }

    this.inputText = query;
    this.sendMessage();
  }

  scrollToBottom() {
    // 这里可以实现滚动到底部的逻辑
  }
}
