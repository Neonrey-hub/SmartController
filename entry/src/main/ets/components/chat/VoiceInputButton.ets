import { promptAction } from '@kit.ArkUI'
import common from '@ohos.app.ability.common';
import { PermissionManager } from '../../managers/PermissionManager';
import { AudioCaptureManager } from '../../managers/AudioCaptureManager';
import { AsrWebSocketManager } from '../../managers/AsrWebSocketManager';
import { network_connect } from "ets/pages/network_connect";


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
@ComponentV2
export struct VoiceInputButton {
  /** 按钮点击回调 —— 语音识别接入后可替换为 onRecordStart / onRecordEnd */
  onButtonClick?: () => void
  @Local recognizedText: string = '';
  @Local isRecording: boolean = false;
  @Local statusText: string = '点击开始识别';
  @Local permissionGranted: boolean = false;
  @Local buttonColor: string = "#3e3e3e"
  private context = getContext(this) as common.UIAbilityContext;
  private audioManager: AudioCaptureManager = new AudioCaptureManager();
  private asrManager: AsrWebSocketManager = new AsrWebSocketManager();

  async aboutToAppear(): Promise<void> {
    this.permissionGranted = await PermissionManager.checkAndRequestPermissions(this.context);
    if (!this.permissionGranted) {
      this.statusText = '缺少必要权限';
      return;
    }
    await this.audioManager.init();
    this.setupAsrCallbacks();
  }

  aboutToDisappear(): void {
    this.audioManager.release();
    this.asrManager.disconnect();
  }

  setupAsrCallbacks(): void {
    this.asrManager.setCallbacks({
      onOpen: () => {
        this.statusText = '连接成功，请说话...';
        this.isRecording = true;
      },
      onResult: (text: string, isFinal: boolean) => {
        this.recognizedText = text;
        if (isFinal) {
          this.statusText = '识别完成';
          this.isRecording = false;
          this.audioManager.stop();
        }
      },
      onError: (error: Error) => {
        this.statusText = `识别出错: ${error.message}`;
        this.isRecording = false;
        this.audioManager.stop();
      },
      onClose: () => {
        this.statusText = '连接已关闭';
        this.isRecording = false;
      }
    });
  }

  async toggleRecording(): Promise<void> {
    console.log("clickSuccess")
    if (!this.permissionGranted) {
      this.permissionGranted = await PermissionManager.checkAndRequestPermissions(this.context);
      if (!this.permissionGranted) {
        return;
      }
    }
    if (this.isRecording) {
      console.log("stop")
      this.stopRecording();
    } else {
      this.startRecording();
    }
  }

  async startRecording(): Promise<void> {
    try {
      this.recognizedText = '';
      await this.asrManager.connect();
      this.audioManager.start((audioData: ArrayBuffer) => {
        this.asrManager.sendAudio(audioData);
      });
    } catch (err) {
      this.statusText = `连接失败: ${JSON.stringify(err)}`;
    }
  }

  stopRecording(): void {
    this.asrManager.sendEnd();
    this.audioManager.stop();
    this.isRecording = false;
    this.statusText = '正在结束识别...';
  }

  build() {
    Row() {
      Text('语音输入')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
    }
    .width('60%')
    .height(56)
    .backgroundColor(this.buttonColor)
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
      this.toggleRecording()
      if (this.recognizedText.length != 0) {
        network_connect.send(this.recognizedText)

      }
      if (this.isRecording) {
        this.buttonColor = "#FFF6D777"

      } else {
        this.buttonColor = "#3e3e3e"

      }

    }

    )

  }
}
