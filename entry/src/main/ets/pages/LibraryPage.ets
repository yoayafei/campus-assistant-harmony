import { BookListPage } from "./BookListPage";
import { BorrowPage } from "./BorrowPage";
import { LibraryChatPage } from "./LibraryChatPage";

// pages/LibraryPage.ets (更新版)
@Entry
@Component
export struct LibraryPage {
  @State currentTab: number = 0;
  private tabsController: TabsController = new TabsController();

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('校园图书馆')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')

        Blank()

        // 消息通知图标
        Text('\ue60b')
          .fontSize(22)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#666666')
          .margin({ right: 16 })
          .onClick(() => {
            // 查看借阅提醒
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 标签页
      Row() {
        this.buildTab('书籍', 0)
        this.buildTab('我的借阅', 1)
        this.buildTab('智能助手', 2)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      // 页面内容
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.currentTab
      }) {
        TabContent() {
          BookListPage()
        }

        TabContent() {
          BorrowPage()
        }

        TabContent() {
          LibraryChatPage()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildTab(text: string, index: number) {
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
    .width('33%')
    .height(40)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = index;
      this.tabsController.changeIndex(index);
    })
  }
}