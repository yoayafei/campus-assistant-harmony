import { BookListPage } from './BookListPage';
import { LibraryChatPage } from './LibraryChatPage'; // 假设智能对话页为LibraryChatPage
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct LibraryMainPage {
  @State currentIndex: number = 0; // 默认选中图书页
  private tabsController: TabsController = new TabsController();

  build() {
    Tabs({
      barPosition: BarPosition.End, // 底部导航
      controller: this.tabsController,
    }) {
      // 图书列表页（索引0）
      TabContent() {
        BookListPage()
      }
      .tabBar(this.buildTabBar('图书', '\ue610', 0))

      // 智能对话页（索引1）
      TabContent() {
        LibraryChatPage()
      }
      .tabBar(this.buildTabBar('智能对话', '\ue67c', 1))
    }
    .backgroundColor('#F5F5F5')
    .barMode(BarMode.Fixed) // 固定高度的导航栏
    .barHeight(56) // 导航栏高度
    .width('100%')
    .height('100%')
    .onChange((index: number) => {
      this.currentIndex = index; // 切换页面时更新选中状态
    })
  }

  // 构建底部导航栏项
  @Builder
  buildTabBar(text: string, icon: string, index: number) {
    Column() {
      // 导航图标
      Text(icon)
        .fontSize(22)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#8A8A8A')
        .fontFamily('HarmonyOS_Sans')
        .margin({ bottom: 2 })

      // 导航文字
      Text(text)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#8A8A8A')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
  }
}
