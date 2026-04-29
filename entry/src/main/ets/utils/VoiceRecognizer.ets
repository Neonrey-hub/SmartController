/**
 * 语音识别结果回调接口
 * 保留此接口定义，供后续接入语音识别引擎时使用
 */
export interface VoiceRecognitionCallback {
  onResult: (text: string) => void
  onStart: () => void
  onStop: () => void
  onError: (error: string) => void
}

/**
 * 语音识别工具类
 *
 * 当前为占位实现，语音识别功能尚未接入。
 * OpenHarmony SDK 12 标准版暂不支持 @kit.AISpeechKit，
 * 后续接入语音识别引擎时，请在此类中实现以下方法：
 *   - init(): 初始化语音识别引擎
 *   - setCallback(): 设置识别结果回调
 *   - startRecognition(): 开始语音识别
 *   - stopRecognition(): 停止语音识别
 *   - cancelRecognition(): 取消语音识别
 *   - destroy(): 销毁引擎释放资源
 *
 * 接入步骤：
 *   1. 在此文件顶部 import 对应的语音识别 Kit（如 @kit.AISpeechKit 或第三方库）
 *   2. 在 init() 中创建并初始化引擎实例
 *   3. 在 applyListener() 中绑定引擎监听器，将引擎回调转发到 VoiceRecognitionCallback
 *   4. 在 startRecognition() / stopRecognition() 中调用引擎的启停接口
 *   5. 在 destroy() 中释放引擎资源
 */
export class VoiceRecognizer {
  private callback: VoiceRecognitionCallback | null = null

  /** TODO: 接入语音识别引擎后，在此初始化引擎实例 */
  async init(): Promise<void> {
    console.log('VoiceRecognizer', '语音识别尚未接入，init() 为占位实现')
  }

  setCallback(callback: VoiceRecognitionCallback): void {
    this.callback = callback
  }

  /** TODO: 接入语音识别引擎后，在此调用引擎的 startListening 接口 */
  async startRecognition(): Promise<void> {
    console.warn('VoiceRecognizer', '语音识别尚未接入，startRecognition() 为占位实现')
    if (this.callback) {
      this.callback.onError('语音识别功能尚未接入')
    }
  }

  /** TODO: 接入语音识别引擎后，在此调用引擎的 finish 接口 */
  async stopRecognition(): Promise<void> {
    console.warn('VoiceRecognizer', '语音识别尚未接入，stopRecognition() 为占位实现')
  }

  /** TODO: 接入语音识别引擎后，在此调用引擎的 cancel 接口 */
  async cancelRecognition(): Promise<void> {
    console.warn('VoiceRecognizer', '语音识别尚未接入，cancelRecognition() 为占位实现')
  }

  /** TODO: 接入语音识别引擎后，在此释放引擎资源 */
  async destroy(): Promise<void> {
    this.callback = null
    console.log('VoiceRecognizer', '语音识别尚未接入，destroy() 为占位实现')
  }
}
