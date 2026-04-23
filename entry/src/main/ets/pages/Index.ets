/** 各 Tab 子页组件：由 Navigation 的 navDestination 按需构建 */
import { ChatPage } from './ChatPage'
import { DataHomePage } from './DataHomePage'
import { DeviceHomePage } from './DeviceHomePage'

/** 底栏 Tab 项数据模型：图标、文案等与 UI 绑定 */
interface BottomTabItem {
  id: string
  label: ResourceStr
  icon: ResourceStr
}

@Entry
@Component
struct Index {
  /** 路由栈：与 Navigation 配合，在对话 / 数据 / 设备子页间切换 */
  private pageStack: NavPathStack = new NavPathStack()
  /** 底栏三项配置：与 pushPathByName 的路由名（ChatPage / DataPage / DevicePage）对应 */
  private readonly bottomTabs: BottomTabItem[] = [
    { id: 'chat', label: $r('app.string.tab_chat'), icon: $r('app.media.startIcon') },
    { id: 'data', label: $r('app.string.tab_data'), icon: $r('app.media.startIcon') },
    { id: 'device', label: $r('app.string.tab_device'), icon: $r('app.media.startIcon') }
  ]
  /** 当前选中的底栏 Tab，用于高亮样式 */
  @State selectedTabId: string = 'chat'

  /** 首屏进入：若栈为空则默认打开对话页 */
  aboutToAppear(): void {
    if (this.pageStack.getAllPathName().length === 0) {
      this.pageStack.pushPathByName('ChatPage', '')
    }
  }

  /** 底栏切换：清空栈后压入对应子页，保证标题与内容与 Tab 一致 */
  private switchBottomTab(tabId: string): void {
    if (this.selectedTabId === tabId) {
      return
    }
    this.pageStack.clear()
    if (tabId === 'chat') {
      this.pageStack.replacePathByName('ChatPage', '')
    } else if (tabId === 'data') {
      this.pageStack.replacePathByName('DataPage', '')
    } else if (tabId === 'device') {
      this.pageStack.replacePathByName('DevicePage', '')
    }
    this.selectedTabId = tabId
  }

  /** 路由名到子页组件的映射：供 Navigation.navDestination 使用 */
  @Builder
  pageMap(name: string, _param: Object) {
    if (name === 'ChatPage') {
      ChatPage()
    } else if (name === 'DataPage') {
      DataHomePage()
    } else if (name === 'DevicePage') {
      DeviceHomePage()
    }
  }

  build() {
    Column() {
      // 主导航区：占满除底栏外的空间；子页内容由 pageMap 注入
      Navigation(this.pageStack) {
        // Navigation 要求非空子节点；零尺寸占位，避免与 NavDestination 重复布局
        Column()
          .width(0)
          .height(0)
      }
      .mode(NavigationMode.Stack)
      .navDestination(this.pageMap)
      .backgroundColor('#081F37')
      .layoutWeight(1)
      .width('100%')

      // 底栏：固定在 Navigation 之外，不随子页内容滚动
      Row() {
        ForEach(this.bottomTabs, (item: BottomTabItem) => {
          Column({ space: 6 }) {
            Stack({ alignContent: Alignment.Center }) {
              Image(item.icon)
                .width(26)
                .height(26)
                .objectFit(ImageFit.Contain)
                .fillColor(this.selectedTabId === item.id ? '#FFD700' : '#999999')
                .align(Alignment.Center)
            }
            .width(40)
            .height(40)

            Text(item.label)
              .fontSize(11)
              .fontColor(this.selectedTabId === item.id ? '#FFD700' : '#999999')
              .textAlign(TextAlign.Center)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            this.switchBottomTab(item.id)
          })
        }, (item: BottomTabItem) => item.id)
      }
      .width('100%')
      .backgroundColor('#081F37')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#081F37')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
