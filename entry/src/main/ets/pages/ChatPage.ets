// entry/src/main/ets/pages/ChatPage.ets
import { network_connect, WebSocket_connect } from "ets/network/network_connect";
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { VoiceInputButton } from '../components/chat/VoiceInputButton'

@ComponentV2
export struct ChatPage {
  @Local network_connect: WebSocket_connect = network_connect;

  build() {
    NavDestination() {
      Column() {
        // ========== 标题栏（含在线状态） ==========
        Row() {
          // 标题文字
          Text($r('app.string.tab_chat'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E0E6F0')

          Blank() // 将状态指示器推到右侧

          // 设备在线/离线状态指示器
          Row({ space: 4 }) {
            // 彩色圆点
            Circle()
              .width(8)
              .height(8)
              .fill(this.network_connect.state ? '#4ADE80' : '#EF4444') // 在线绿色，离线红色
            // 状态文字
            Text(this.network_connect.state ? '在线' : '离线')
              .fontSize(12)
              .fontColor(this.network_connect.state ? '#4ADE80' : '#EF4444')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.network_connect.state ? '#4ADE8020' : '#EF444420') // 半透明背景
          .borderRadius(12)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#081F37')
        .padding({ left: 20, right: 20 })

        // ========== 消息列表（保持不变） ==========
        List() {
          ForEach(network_connect.str_arr, (item: string[], key: number) => {
            ListItem() {
              // 用户消息（右侧）
              if (item[1] == "0") {
                Row() {
                  Blank()
                  Column() {
                    Text(item[0])
                      .fontSize(16).fontColor('#FFFFFF').padding(12)
                      .backgroundColor('#1E5A99')
                      .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
                      .constraintSize({ maxWidth: '80%' })
                  }
                  .margin({ left: 40, right: 16, top: 6, bottom: 6 })
                }
                .width("100%")

              }
              // 服务器消息（左侧）
              else if (item[1] == "1") {
                Row() {
                  Column() {
                    Text(item[0])
                      .fontSize(16).fontColor('#D0D8E8').padding(12)
                      .backgroundColor('#122744')
                      .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
                      .constraintSize({ maxWidth: '80%' })
                  }
                  .margin({ left: 16, right: 40, top: 6, bottom: 6 })
                  Blank()
                }
                .width("100%")

              }
            }
            .width("100%")
          })
        }
        .layoutWeight(1).width('100%').scrollBar(BarState.Auto).edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#0A1428').padding({ top: 8, bottom: 8 })

        // ========== 底部输入区 ==========
        Row() { VoiceInputButton() }
        .width('100%').height(110).justifyContent(FlexAlign.Center).backgroundColor('#0A1428')
        .border({ width: { top: 1 }, color: '#1E2A3A' })
      }
      .width('100%').height('100%').backgroundColor('#081F37')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (ExitConfirmManager.handleBackPress()) {
        promptAction.showToast({ message: '再按一次退出应用', duration: 2000, bottom: 500 });
        return true;
      }
      return false;
    })
  }
}