import { promptAction } from '@kit.ArkUI'

/**
 * 语音输入按钮组件
 * 当前为点击提示模式，语音识别功能接入后可恢复长按识别交互
 *
 * TODO: 接入语音识别引擎后，可恢复以下功能：
 *   1. 将 onClick 改为 LongPressGesture 长按识别
 *   2. 在 onAction 中调用 VoiceRecognizer.startRecognition()
 *   3. 在 onActionEnd 中调用 VoiceRecognizer.stopRecognition()
 *   4. 通过 onRecordStart / onRecordEnd 回调通知父组件
 */
@Component
export struct VoiceInputButton {
  /** 按钮点击回调 —— 语音识别接入后可替换为 onRecordStart / onRecordEnd */
  onButtonClick?: () => void

  build() {
    Row() {
      Text('语音输入')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
    }
    .width('60%')
    .height(56)
    .backgroundColor('#333333')
    .borderRadius(28)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.2)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      // 当前为占位提示，语音识别接入后替换为识别逻辑
      promptAction.showToast({
        message: '语音识别功能开发中，敬请期待',
        duration: 2000
      })
      if (this.onButtonClick) {
        this.onButtonClick()
      }
    })
  }
}
