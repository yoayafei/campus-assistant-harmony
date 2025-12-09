import { ChatPage } from './ChatPage';
import { AppsPage } from './AppsPage';
import { ProfilePage } from './ProfilePage';
import { ConversationListPage } from './ConversationListPage'

@Entry
@Component
struct Index {
  @State currentIndex: number = 1; // 默认选中应用页

  private tabsController: TabsController = new TabsController();

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      // 对话页面
      TabContent() {
        ConversationListPage()
      }
      .tabBar(this.buildTabBar('对话', '\ue60a', 0))

      // 应用页面
      TabContent() {
        AppsPage()
      }
      .tabBar(this.buildTabBar('工作台', '\ue60e', 1))

      // 个人页面
      TabContent() {
        ProfilePage()
      }
      .tabBar(this.buildTabBar('个人', '\ue608', 2))
    }
    .backgroundColor('#F5F5F5')
    .barMode(BarMode.Fixed)
    .barHeight(56)
    .width('100%')
    .height('100%')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  // 构建底部导航栏项
  @Builder
  buildTabBar(text: string, icon: string, index: number) {
    Column() {
      // 图标
      Text(icon)
        .fontSize(24)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#8A8A8A')
        .fontFamily('HarmonyOS_Sans')
        .margin({ bottom: 2 })

      // 文字
      Text(text)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#8A8A8A')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}