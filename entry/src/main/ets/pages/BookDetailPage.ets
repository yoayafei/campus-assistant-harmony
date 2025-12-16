// pages/BookDetailPage.ets
import { Book, BorrowBookRequest } from '../model/Book';
import { LibraryService } from '../service/LibraryService';
import router from '@ohos.router';
import prompt from '@ohos.prompt';

@Entry
@Component
export struct BookDetailPage {
  @State book: Book | null = null;
  @State isLoading: boolean = true;
  @State canBorrow: boolean = true;

  private bookId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params['bookId']) {
      this.bookId = params['bookId'];
      this.loadBookDetail();
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#007DFF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (!this.book) {
        Column() {
          Image($r('app.media.error'))
            .width(120)
            .height(120)
          Text('图书信息加载失败')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
          Button('重新加载')
            .margin({ top: 20 })
            .onClick(() => this.loadBookDetail())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        this.buildBookDetail()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildBookDetail() {
    Scroll() {
      Column({ space: 0 }) {
        // 图书封面
        Column() {
          if (this.book?.coverUrl) {
            Image(this.book.coverUrl)
              .width(180)
              .height(240)
              .objectFit(ImageFit.Cover)
              .borderRadius(12)
          } else {
            Column() {
              Text(this.book!.title.charAt(0))
                .fontSize(48)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
            }
            .width(180)
            .height(240)
            .backgroundColor('#007DFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .padding({ top: 24, bottom: 24 })
        .justifyContent(FlexAlign.Center)

        // 图书信息卡片
        Column({ space: 16 }) {
          // 标题和状态
          Row() {
            Column({ space: 4 }) {
              Text(this.book!.title)
                .fontSize(22)
                .fontColor('#000000')
                .fontWeight(FontWeight.Bold)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(this.book!.author)
                .fontSize(16)
                .fontColor('#666666')
                .maxLines(1)
            }
            .width('70%')

            // 状态标签
            Column() {
              Text(this.book!.availableCopies > 0 ? '可借' : '无货')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor(this.book!.availableCopies > 0 ? '#4CAF50' : '#F44336')
                .borderRadius(12)
            }
          }
          .width('100%')

          // 基本信息
          Column({ space: 8 }) {
            this.buildInfoItem('出版社', this.book!.publisher)
            this.buildInfoItem('出版年份', this.book!.publishDate.toString())
            this.buildInfoItem('分类', this.book!.category)
            this.buildInfoItem('库存', `${this.book!.availableCopies}/${this.book!.totalCopies}`)
            if (this.book!.borrowRate) {
              this.buildInfoItem('借阅率', `${this.book!.borrowRate}%`)
            }
          }

          // 描述
          if (this.book!.description) {
            Column({ space: 8 }) {
              Text('内容简介')
                .fontSize(16)
                .fontColor('#000000')
                .fontWeight(FontWeight.Medium)
              Text(this.book!.description)
                .fontSize(14)
                .fontColor('#666666')
                .lineHeight(20)
            }
            .width('100%')
            .padding({ top: 8 })
          }

          // 操作按钮
          Row({ space: 12 }) {
            if (this.canBorrow && this.book!.availableCopies > 0) {
              Button('立即借阅', { type: ButtonType.Normal })
                .width('70%')
                .height(50)
                .backgroundColor('#007DFF')
                .fontColor('#FFFFFF')
                .fontSize(16)
                .borderRadius(25)
                .onClick(() => this.borrowBook())
            } else {
              Button('暂不可借', { type: ButtonType.Normal })
                .width('70%')
                .height(50)
                .backgroundColor('#CCCCCC')
                .fontColor('#666666')
                .fontSize(16)
                .borderRadius(25)
                .enabled(false)
            }

            Button('咨询智能体', { type: ButtonType.Capsule })
              .width('25%')
              .height(50)
              .backgroundColor('#FFFFFF')
              .fontColor('#007DFF')
              .fontSize(14)
              .border({ width: 1, color: '#007DFF' })
              .onClick(() => this.consultAssistant())
          }
          .width('100%')
          .margin({ top: 24, bottom: 32 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .margin({ top: -20 })
      }
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .flexGrow(1)
    }
    .width('100%')
  }

  async loadBookDetail() {
    try {
      this.isLoading = true;
      this.book = await LibraryService.getBookDetail(this.bookId);
      this.canBorrow = await LibraryService.checkUserCanBorrow();
    } catch (error) {
      console.error('加载图书详情失败:', error);
      prompt.showToast({
        message: '加载失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  async borrowBook() {
    try {
      // 明确声明 request 的类型
      const request: BorrowBookRequest = {
        bookId: this.bookId,
        days: 30
      };

      const result = await LibraryService.borrowBook(request);
      prompt.showToast({
        message: '借阅成功',
        duration: 2000
      });

      // 刷新图书信息
      await this.loadBookDetail();
    } catch (error) {
      console.error('借阅失败:', error);

      // 需要将 error 转换为 string
      let errorMessage = '借阅失败';
      if (error instanceof Error) {
        errorMessage = error.message;
      } else if (typeof error === 'string') {
        errorMessage = error;
      } else if (error && typeof error === 'object') {
        errorMessage = JSON.stringify(error);
      }

      prompt.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }

  consultAssistant() {
    router.pushUrl({
      url: 'pages/LibraryChatPage',
      params: {
        initialQuery: `我想了解《${this.book!.title}》这本书`
      }
    });
  }
}