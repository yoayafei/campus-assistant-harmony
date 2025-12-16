// pages/BorrowPage.ets
import { BorrowRecord, BorrowRecordResponse, BorrowStatusResponse, RenewBookRequest } from '../model/BorrowRecord';
import { LibraryService } from '../service/LibraryService';
import { prompt } from '@kit.ArkUI';

@Entry
@Component
export struct BorrowPage {
  @State borrowRecords: BorrowRecord[] = [];
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State borrowStatus: BorrowStatusResponse | null = null;

  aboutToAppear() {
    this.loadBorrowData();
  }

  async loadBorrowData() {
    try {
      this.isLoading = true;

      const status = await LibraryService.getBorrowStatus();
      const recordsResponse = await LibraryService.getBorrowRecords(1, 100);

      // 使用类型断言
      this.borrowStatus = status as BorrowStatusResponse;
      this.borrowRecords = recordsResponse.records as BorrowRecordResponse[];
    } catch (error) {
      console.error('加载借阅数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 借阅状态标签
      Row() {
        this.buildStatusTab('借阅中', 0)
        this.buildStatusTab('历史记录', 1)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

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
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else if (this.getFilteredRecords().length === 0) {
        Column() {
          Image($r('app.media.no_borrow'))
            .width(120)
            .height(120)
          Text(this.currentTab === 0 ? '暂无借阅记录' : '暂无历史记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.getFilteredRecords(), (record: BorrowRecord) => {
            ListItem() {
              this.buildBorrowItem(record)
            }
          }, (record: BorrowRecord) => record.id.toString())
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildStatusTab(text: string, index: number) {
    Column() {
      Text(text)
        .fontSize(14)
        .fontColor(this.currentTab === index ? '#007DFF' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)

      if (this.currentTab === index) {
        Divider()
          .width(20)
          .height(2)
          .color('#007DFF')
          .margin({ top: 4 })
      }
    }
    .width('50%')
    .height(40)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = index;
    })
  }

  @Builder
  buildBorrowItem(record: BorrowRecord) {
    Column({ space: 12 }) {
      // 书籍信息
      Row() {
        Column({ space: 2 }) {
          Text(record.bookTitle)
            .fontSize(16)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('70%')

        // 状态标签 - 使用数字比较
        Column() {
          Text(this.getStatusText(record.status))
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.getStatusColor(record.status))
            .borderRadius(10)
        }
      }

      // 借阅信息
      Row() {
        Column() {
          Text('借阅日期')
            .fontSize(12)
            .fontColor('#999999')
          Text(this.formatDate(record.borrowDate))
            .fontSize(14)
            .fontColor('#333333')
            .margin({ top: 2 })
        }
        .width('33%')

        Column() {
          Text('应还日期')
            .fontSize(12)
            .fontColor('#999999')
          Text(this.formatDate(record.dueDate))
            .fontSize(14)
            .fontColor(record.status === 2 ? '#F44336' : '#333333') // 使用数字比较
            .margin({ top: 2 })
        }
        .width('33%')

        Column() {
          if (record.status === 0) { // 使用数字比较
            Button('续借', { type: ButtonType.Normal })
              .fontSize(12)
              .backgroundColor('#007DFF')
              .borderRadius(15)
              .width(60)
              .height(30)
              .onClick(() => {
                this.renewBook(record.id);
              })
          } else if (record.status === 2) { // 使用数字比较
            Text('已逾期')
              .fontSize(12)
              .fontColor('#F44336')
          }
        }
        .width('33%')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  getFilteredRecords(): BorrowRecord[] {
    if (this.currentTab === 0) {
      return this.borrowRecords.filter(record => record.status !== 1); // 使用数字比较
    } else {
      return this.borrowRecords.filter(record => record.status === 1); // 使用数字比较
    }
  }

  getStatusText(status: number): string {
    switch (status) {
      case 0: return '借阅中';
      case 1: return '已归还';
      case 2: return '已逾期';
      default: return '';
    }
  }

  getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#4CAF50';
      case 1: return '#9E9E9E';
      case 2: return '#F44336';
      default: return '';
    }
  }

  formatDate(dateString: string): string {
    // 格式化日期，只显示年月日
    if (!dateString) return '';
    try {
      return dateString.substring(0, 10);
    } catch (error) {
      return dateString;
    }
  }

  async renewBook(recordId: number) {
    try {
      // 直接传递参数，不创建对象
      const result: BorrowRecordResponse = await LibraryService.renewBook({
        recordId: recordId,
        additionalDays: 15
      }) as BorrowRecordResponse;

      if (result) {
        prompt.showToast({
          message: '续借成功',
          duration: 2000
        });
        await this.loadBorrowData();
      }
    } catch (error) {
      console.error('续借失败:', error);

      let errorMessage = '续借失败';
      if (error instanceof Error) {
        errorMessage = error.message;
      } else if (typeof error === 'string') {
        errorMessage = error;
      }

      prompt.showToast({
        message: errorMessage,
        duration: 2000
      });
    }
  }
}