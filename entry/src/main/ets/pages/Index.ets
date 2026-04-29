// entry/src/main/ets/pages/Index.ets
import { ChatPage } from './ChatPage'
import { DataHomePage } from './DataHomePage'
import { DeviceHomePage } from './DeviceHomePage'

interface BottomTabItem { id: string; label: ResourceStr; icon: ResourceStr; }

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack()
  private readonly bottomTabs: BottomTabItem[] = [
    { id: 'chat', label: $r('app.string.tab_chat'), icon: $r('app.media.startIcon') },
    { id: 'data', label: $r('app.string.tab_data'), icon: $r('app.media.startIcon') },
    { id: 'device', label: $r('app.string.tab_device'), icon: $r('app.media.startIcon') }
  ]
  @State selectedTabId: string = 'chat'

  aboutToAppear(): void { if (this.pageStack.getAllPathName().length === 0) this.pageStack.pushPathByName('ChatPage', '') }

  private switchBottomTab(tabId: string): void {
    if (this.selectedTabId === tabId) return
    if (tabId === 'chat') this.pageStack.replacePathByName('ChatPage', '')
    else if (tabId === 'data') this.pageStack.replacePathByName('DataPage', '')
    else if (tabId === 'device') this.pageStack.replacePathByName('DevicePage', '')
    this.selectedTabId = tabId
  }

  @Builder pageMap(name: string, _param: Object) {
    if (name === 'ChatPage') { ChatPage() }
    else if (name === 'DataPage') { DataHomePage() }
    else if (name === 'DevicePage') { DeviceHomePage() }
  }

  build() {
    Column() {
      Navigation(this.pageStack) { Column().width(0).height(0) }
      .mode(NavigationMode.Stack)
      .navDestination(this.pageMap)
      .backgroundColor('#081F37')
      .layoutWeight(1)
      .width('100%')

      Row() {
        ForEach(this.bottomTabs, (item: BottomTabItem) => {
          Column({ space: 4 }) {
            Image(item.icon)
              .width(24).height(24).objectFit(ImageFit.Contain)
              .fillColor(this.selectedTabId === item.id ? '#FFD700' : '#8899AA')
            Text(item.label)
              .fontSize(12)
              .fontColor(this.selectedTabId === item.id ? '#FFD700' : '#8899AA')
          }
          .layoutWeight(1).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
          .padding({ top: 8, bottom: 8 })
          .onClick(() => { this.switchBottomTab(item.id) })
        })
      }
      .width('100%').backgroundColor('#081F37')
    }
    .width('100%').height('100%').backgroundColor('#081F37')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}