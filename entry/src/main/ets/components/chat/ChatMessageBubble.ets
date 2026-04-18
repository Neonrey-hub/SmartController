import { ChatMessage } from '../../models/ChatMessage'

/**
 * 对话气泡组件
 */
@Component
export struct ChatMessageBubble {
  @Prop message: ChatMessage

  build() {
    Row() {
      if (this.message.type === 'system') {
        // 系统消息 - 右侧
        Column() {
          Text(this.message.content)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .backgroundColor('#CCCCCC')
        .borderRadius(20)
      } else {
        // 用户消息 - 左侧
        Column() {
          Text(this.message.content)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .backgroundColor('#666666')
        .borderRadius(20)
      }
    }
    .width('100%')
    .justifyContent(this.message.type === 'system' ? FlexAlign.End : FlexAlign.Start)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
}