@Component
@Entry
export struct ProfilePage {
  @State userInfo: UserInfo = {
    name: '张三',
    studentId: '20230001',
    avatar: '',
    college: '计算机科学与技术学院',
    major: '软件工程',
    grade: '2023级',
    points: 1280
  };

  @State menuItems: MenuItem[] = [
    { id: 1, name: '我的课程', icon: '\ue61a', hasArrow: true },
    { id: 2, name: '我的成绩', icon: '\ue61b', hasArrow: true },
    { id: 3, name: '借阅记录', icon: '\ue61c', hasArrow: true },
    { id: 4, name: '消费记录', icon: '\ue61d', hasArrow: true },
    { id: 5, name: '我的收藏', icon: '\ue61e', hasArrow: true },
    { id: 6, name: '设置', icon: '\ue61f', hasArrow: true },
    { id: 7, name: '关于我们', icon: '\ue620', hasArrow: true },
    { id: 8, name: '退出登录', icon: '\ue621', hasArrow: false }
  ];

  build() {
    Column() {
      // 用户信息卡片
      Column() {
        // 头像和基本信息
        Row() {
          // 头像
          Column() {
            if (this.userInfo.avatar) {
              // 如果有头像则显示头像
              Image(this.userInfo.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
            } else {
              // 默认头像
              Text('\ue608')
                .fontSize(40)
                .fontFamily('HarmonyOS_Sans')
                .fontColor('#FFFFFF')
            }
          }
          .width(80)
          .height(80)
          .backgroundColor('#007DFF')
          .borderRadius(40)
          .justifyContent(FlexAlign.Center)

          // 用户信息
          Column() {
            Row() {
              Text(this.userInfo.name)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')

              // 会员标识
              Text('学生')
                .fontSize(10)
                .fontColor('#FFFFFF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#FF9800')
                .borderRadius(8)
                .margin({ left: 8 })
            }
            .margin({ bottom: 6 })

            Text(`学号: ${this.userInfo.studentId}`)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.9)
              .margin({ bottom: 4 })

            Text(`${this.userInfo.college}`)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.8)

            Text(`${this.userInfo.major} ${this.userInfo.grade}`)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.8)
              .margin({ top: 2 })
          }
          .margin({ left: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        // 积分和编辑资料
        Row() {
          // 积分
          Column() {
            Text(this.userInfo.points.toString())
              .fontSize(18)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)

            Text('校园积分')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.8)
          }
          .margin({ right: 24 })

          // 编辑资料按钮
          Row() {
            Text('编辑资料')
              .fontSize(14)
              .fontColor('#FFFFFF')

            Text('\ue6a3')
              .fontSize(14)
              .fontFamily('HarmonyOS_Sans')
              .fontColor('#FFFFFF')
              .margin({ left: 4 })
          }
          .width(88)
          .height(32)
          .backgroundColor('#FFFFFF20')
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            // 编辑资料
          })
        }
        .margin({ top: 20 })
      }
      .width('100%')
      .padding({ top: 40, bottom: 32, left: 24, right: 24 })
      .backgroundColor('#007DFF')

      // 功能菜单列表
      Scroll() {
        Column() {
          ForEach(this.menuItems, (item: MenuItem) => {
            Row() {
              // 图标
              Text(item.icon)
                .fontSize(20)
                .fontFamily('HarmonyOS_Sans')
                .fontColor('#007DFF')
                .margin({ right: 16 })

              // 菜单名称
              Text(item.name)
                .fontSize(16)
                .fontColor('#333333')
                .fontWeight(item.id === 8 ? FontWeight.Medium : FontWeight.Normal)

              Blank()

              // 箭头
              if (item.hasArrow) {
                Text('\ue6a7')
                  .fontSize(18)
                  .fontFamily('HarmonyOS_Sans')
                  .fontColor('#999999')
              }
            }
            .width('100%')
            .height(56)
            .padding({ left: 24, right: 20 })
            .backgroundColor('#FFFFFF')
            .onClick(() => {
              this.handleMenuItemClick(item);
            })

            // 分隔线（除了最后一个）
            if (item.id < this.menuItems.length) {
              Divider()
                .strokeWidth(0.5)
                .color('#F0F0F0')
                .margin({ left: 64, right: 0 })
            }
          })
        }
        .width('100%')
        .margin({ top: 16 })
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .flexGrow(1)

      // 底部信息
      Column() {
        Text('CampusHarmony v1.0.0')
          .fontSize(12)
          .fontColor('#999999')

        Text('© 2024 智能校园助手')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .width('100%')
      .padding({ top: 24, bottom: 24 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F6F6')
  }

  // 处理菜单项点击
  handleMenuItemClick(item: MenuItem) {
    console.log(`点击菜单: ${item.name}`);
    // 这里可以添加菜单项点击后的逻辑
  }
}

// 用户信息数据模型
interface UserInfo {
  name: string;
  studentId: string;
  avatar: string;
  college: string;
  major: string;
  grade: string;
  points: number;
}

// 菜单项数据模型
interface MenuItem {
  id: number;
  name: string;
  icon: string;
  hasArrow: boolean;
}