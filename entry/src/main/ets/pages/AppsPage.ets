@Component
@Entry
export struct AppsPage {
  @State appList: AppItem[] = [
    { id: 1, name: '课程表', icon: '\ue60e', color: '#4CAF50', description: '查看课程安排' },
    { id: 2, name: '成绩查询', icon: '\ue60f', color: '#2196F3', description: '查询考试成绩' },
    { id: 3, name: '图书馆', icon: '\ue610', color: '#FF9800', description: '借阅图书' },
    { id: 4, name: '校园卡', icon: '\ue611', color: '#9C27B0', description: '校园卡管理' },
    { id: 5, name: '校园导航', icon: '\ue612', color: '#F44336', description: '校内导航' },
    { id: 6, name: '食堂菜单', icon: '\ue613', color: '#00BCD4', description: '查看今日菜单' },
    { id: 7, name: '校车查询', icon: '\ue614', color: '#8BC34A', description: '校车时刻表' },
    { id: 8, name: '活动中心', icon: '\ue615', color: '#FF5722', description: '校园活动' },
    { id: 9, name: '失物招领', icon: '\ue616', color: '#795548', description: '失物招领平台' },
    { id: 10, name: '校园新闻', icon: '\ue617', color: '#607D8B', description: '校园动态' },
    { id: 11, name: '在线报修', icon: '\ue618', color: '#3F51B5', description: '故障报修' },
    { id: 12, name: '更多', icon: '\ue619', color: '#9E9E9E', description: '更多应用' }
  ];

  @State searchText: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('校园应用')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')

        Blank()

        Text('\ue67c')
          .fontSize(22)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#007DFF')
          .onClick(() => {
            // 搜索功能
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
          .margin({ left: 12 })

        TextInput({ placeholder: '搜索应用...', text: this.searchText })
          .width('100%')
          .height(40)
          .padding({ left: 8 })
          .fontSize(16)
          .onChange((value: string) => {
            this.searchText = value;
          })
      }
      .width('100%')
      .height(48)
      .margin({ top: 8, left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })

      // 常用应用提示
      Row() {
        Text('常用功能')
          .fontSize(14)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)

        Blank()

        Text('编辑')
          .fontSize(12)
          .fontColor('#007DFF')
          .onClick(() => {
            // 编辑常用应用
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 8 })

      // 应用网格
      Scroll() {
        Grid() {
          ForEach(this.appList, (item: AppItem) => {
            GridItem() {
              this.buildAppItem(item)
            }
          }, (item: AppItem) => item.id.toString())
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(12)
        .rowsGap(16)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 20 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F6F6')
  }

  @Builder
  buildAppItem(item: AppItem) {
    Column() {
      // 应用图标
      Column() {
        Text(item.icon)
          .fontSize(22)
          .fontFamily('HarmonyOS_Sans')
          .fontColor('#FFFFFF')
      }
      .width(56)
      .height(56)
      .backgroundColor(item.color)
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 8 })

      // 应用名称
      Text(item.name)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 2 })

      // 应用描述
      Text(item.description)
        .fontSize(11)
        .fontColor('#999999')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.openApp(item);
    })
  }

  // 打开应用
  openApp(app: AppItem) {
    console.log(`打开应用: ${app.name}`);
    // 这里可以添加打开具体应用的逻辑
  }
}

// 应用数据模型
interface AppItem {
  id: number;
  name: string;
  icon: string;
  color: string;
  description: string;
}