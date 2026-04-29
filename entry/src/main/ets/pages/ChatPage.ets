import { ChatMessage } from '../models/ChatMessage'
import { ChatMessageBubble } from '../components/chat/ChatMessageBubble'
import { VoiceInputButton } from '../components/chat/VoiceInputButton'
import { DateUtils } from '../utils/DateUtils'
import { network_connect , WebSocket_connect} from "ets/pages/network_connect";
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting , setting} from "ets/pages/get_data";

/**
 * 对话页面：承载语音交互对话功能
 */
@ComponentV2
export struct ChatPage {
  @Local network_connect: WebSocket_connect = network_connect;
  @Local data_setting: setting = data_setting;

  /** 对话消息列表 */
   @Local  messages: ChatMessage[] = [
    { id: '1', type: 'system', content: '你好，我是智能助手', timestamp: DateUtils.getCurrentDateTime() }
  ]
  /** 是否正在录音 */
  @Local isRecording: boolean = false
  private scroller: Scroller = new Scroller()

  build() {
    NavDestination() {
      Column() {
        // 顶部区域（包含状态栏和标题栏）
        Column() {
          // 自定义顶栏
          Row() {
            Text($r('app.string.tab_chat'))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .backgroundColor('#081f37')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

        // 对话内容区


        // Scroll(this.scroller) {
        //   Column() {
        //     ForEach(this.messages, (message: ChatMessage) => {
        //       ChatMessageBubble({ message: message })
        //     }, (message: ChatMessage) => message.id)
        //   }
        //   .width('100%')
        //   .padding({ top: 16, bottom: 80 })
        // }
        // .layoutWeight(1)
        // .width('100%')
        // .scrollBar(BarState.Auto)
        // .edgeEffect(EdgeEffect.Spring)
        // .backgroundColor('#0e1626')
        List(){
          ForEach(network_connect.str_arr,
            (item:string[],key:number)=>{
              /**
               * [["你好","0"]，["1111","1"]] 0代表用户发送 1代表服务器发送
               */
              ListItem(){
                if (item[1] == "0") {
                  Text(item[0])
                    .textAlign(TextAlign.End)
                    .fontColor(Color.White)
                    .fontSize(20)
                    .width('100%')

                }else if (item[1] == "1") {
                  Text(item[0])
                    .textAlign(TextAlign.Start)
                    .fontColor(Color.White)
                    .fontSize(20)
                    .width('100%')

                }
              }
            })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#0e1626')

        //底部操作区
        Column() {
          VoiceInputButton()
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#0e1626')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0e1626')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      // 调用全局退出确认管理器
      if (ExitConfirmManager.handleBackPress()) {
        // 拦截返回，显示提示
        promptAction.showToast({
          message: '再按一次退出应用',
          duration: 2000,
          bottom:500

        })
        return true  // 拦截
      }
      return false  // 允许退出
    })
  }

  /**
   * 发送消息
   * @param text 语音识别的文本内容
   */
  private sendMessage(text: string): void {
    const newMessage: ChatMessage = {
      id: Date.now().toString(),
      type: 'user',
      content: text,
      timestamp: DateUtils.getCurrentDateTime()
    }
    this.messages.push(newMessage)

    // 滚动到底部
    this.scroller.scrollToIndex(this.messages.length - 1)

    // 模拟系统回复（可以根据识别内容进行不同的回复）
    setTimeout(() => {
      let replyContent = '收到您的消息'
      if (text.includes('打开')) {
        replyContent = '已为您打开设备'
      } else if (text.includes('关闭')) {
        replyContent = '已为您关闭设备'
      } else if (text.includes('温度') || text.includes('湿度')) {
        replyContent = '当前环境数据正常'
      }

      const replyMessage: ChatMessage = {
        id: (Date.now() + 1).toString(),
        type: 'system',
        content: replyContent,
        timestamp: DateUtils.getCurrentDateTime()
      }
      this.messages.push(replyMessage)
      this.scroller.scrollToIndex(this.messages.length - 1)
    }, 1000)
  }
}