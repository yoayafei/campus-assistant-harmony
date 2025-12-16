// pages/BookListPage.ets
import { Book, BookSearchRequest } from '../model/Book';
import { BookDetailPage } from './BookDetailPage';
import { LibraryService } from '../service/LibraryService';
import { prompt, router } from '@kit.ArkUI';


@Entry
@Component
export struct BookListPage {
  @State bookList: Book[] = [];
  @State allBookList: Book[] = [];
  @State searchText: string = '';
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false; // 新增刷新状态
  @State selectedCategory: string = '全部';

  private categories: string[] = ['全部', '计算机', '科幻文学', '当代文学', '世界文学', '历史', '经济管理','教材'];

  aboutToAppear() {
    this.loadBooks();
  }

  build() {
    Column() {
      // 搜索和筛选栏
      Row() {
        // 搜索框
        Row() {
          Text('\ue67c')
            .fontSize(18)
            .fontFamily('HarmonyOS_Sans')
            .fontColor('#999999')
            .margin({ left: 12 })

          TextInput({ placeholder: '搜索图书...', text: this.searchText })
            .width('100%')
            .height(40)
            .padding({ left: 8 })
            .fontSize(16)
            .onChange((value: string) => {
              this.searchText = value;
              this.searchBooks();
            })
        }
        .width('70%')
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .margin({ right: 12 })

        // 筛选按钮
        Row() {
          Text('\ue615')
            .fontSize(20)
            .fontFamily('HarmonyOS_Sans')
            .fontColor('#666666')
          Text('筛选')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .height(40)
        .padding({ left: 12, right: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          // 打开筛选弹窗
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 分类标签
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(13)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
              .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Normal)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(this.selectedCategory === category ? '#007DFF' : '#F0F0F0')
              .borderRadius(15)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category;
                this.filterByCategory();
              })
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // 书籍列表
      if (this.isLoading) {
        // 加载中UI
        Column() {
          LoadingProgress()
            .color('#007DFF')
            .width(40)
            .height(40)
          Text('正在加载图书...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: this.isRefreshing }) {
          if (this.bookList.length === 0) {
            Column() {
              Text('\ue616')
                .fontSize(60)
                .fontColor('#E0E0E0')
              Text('暂无图书数据')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .width('100%')
            .height('200')
            .justifyContent(FlexAlign.Center)
          } else {
            List({ space: 12 }) {
              ForEach(this.bookList, (book: Book) => {
                ListItem() {
                  this.buildBookItem(book)
                }
              }, (book: Book) => book.id.toString())
            }
          }
        }
        .onRefreshing(() => {
          this.refreshBooks();
        })
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildBookItem(book: Book) {
    Row() {
      // 图书封面
      Column() {
        if (book.coverUrl) {
          Image(book.coverUrl)
            .width(60)
            .height(80)
            .objectFit(ImageFit.Cover)
            .borderRadius(4)
        } else {
          Column() {
            Text(book.title.charAt(0))
              .fontSize(20)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .width(60)
          .height(80)
          .backgroundColor('#007DFF')
          .borderRadius(4)
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ right: 12 })

      // 图书信息
      Column({ space: 4 }) {
        Text(book.title)
          .fontSize(16)
          .fontColor('#000000')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`作者: ${book.author}`)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(1)

        Text(`出版社: ${book.publisher}`)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(1)

        Row() {
          Text(`库存: ${book.availableCopies}/${book.totalCopies}`)
            .fontSize(12)
            .fontColor(book.availableCopies > 0 ? '#4CAF50' : '#F44336')

          Blank()

          Text(book.category)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#007DFF')
            .borderRadius(10)
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('70%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/BookDetailPage',
        params: { bookId: book.id }
      });
    })
  }

  async loadBooks() {
    try {
      this.isLoading = true;
      const books = await LibraryService.getBooks();
      this.allBookList = books; // 保存所有图书到本地
      this.bookList = books; // 初始显示所有图书
    } catch (error) {
      console.error('加载书籍失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 刷新数据的方法
  async refreshBooks() {
    this.isRefreshing = true;
    await this.loadBooks();
    this.filterByCategory(); // 刷新后重新应用分类筛选
    this.isRefreshing = false;
  }

  async searchBooks() {
    try {
      this.isLoading = true;
      if (this.searchText.trim()) {
        const request: BookSearchRequest = {
          keyword: this.searchText.trim(),
          pageNum: 1,
          pageSize: 100
        };
        const response = await LibraryService.searchBooks(request);
        this.allBookList = response.records; // 搜索结果更新到allBookList
        this.filterByCategory(); // 搜索后保留分类筛选
      } else {
        await this.loadBooks();
      }
    } catch (error) {
      console.error('搜索书籍失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  async filterByCategory() {
    if (this.selectedCategory === '全部') {
      // 显示所有图书
      this.bookList = this.allBookList;
    } else {
      // 根据category字段本地过滤
      this.bookList = this.allBookList.filter(book => {
        // 注意：确保图书的category字段与筛选的分类名称完全一致（如“文学”对应“文学”，避免大小写/空格问题）
        return book.category === this.selectedCategory;
      });
    }
  }





}