// entry/src/main/ets/components/chat/VoiceInputButton.ets
import { PermissionManager } from '../../managers/PermissionManager';
import { AudioCaptureManager } from '../../managers/AudioCaptureManager';
import { AsrWebSocketManager } from '../../managers/AsrWebSocketManager';
import { network_connect } from "ets/network/network_connect";
import common from '@ohos.app.ability.common';

@ComponentV2
export struct VoiceInputButton {
  @Local recognizedText: string = '';
  @Local isRecording: boolean = false;
  @Local statusText: string = '点击开始识别';
  @Local permissionGranted: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private audioManager: AudioCaptureManager = new AudioCaptureManager();
  private asrManager: AsrWebSocketManager = new AsrWebSocketManager();
  private timerId: number = -1;

  async aboutToAppear(): Promise<void> {
    this.permissionGranted = await PermissionManager.checkAndRequestPermissions(this.context);
    if (!this.permissionGranted) { this.statusText = '缺少必要权限'; return; }
    await this.audioManager.init();
    this.setupAsrCallbacks();
  }

  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
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
        if (isFinal && text.length > 0) {


          // 发送设备控制指令（允许失败）
          try {
            network_connect.send(text).catch((e: Error) => console.warn('发送设备指令失败:', e.message));
          } catch (e) { /* 忽略异常 */ }
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
    if (!this.permissionGranted) {
      this.permissionGranted = await PermissionManager.checkAndRequestPermissions(this.context);
      if (!this.permissionGranted) return;
    }
    if (this.isRecording) this.stopRecording();
    else this.startRecording();
  }

  async startRecording(): Promise<void> {
    try {
      this.recognizedText = '';
      this.statusText = '正在连接...';
      this.timerId = setTimeout(() => {
        this.statusText = '连接超时，请重试';
        this.isRecording = false;
        this.asrManager.disconnect();
      }, 7000);
      await this.asrManager.connect();
      clearTimeout(this.timerId);
      this.timerId = -1;
      this.audioManager.start((audioData: ArrayBuffer) => {
        this.asrManager.sendAudio(audioData);
      });
    } catch (err) {
      clearTimeout(this.timerId);
      this.timerId = -1;
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
    Column() {
      if (this.recognizedText) {
        Text(this.recognizedText)
          .fontSize(14).fontColor('#000000').maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding(8).backgroundColor('#F0F9FF').borderRadius(8)
          .constraintSize({ maxWidth: '90%' }).margin({ bottom: 8 })
      }
      Text(this.statusText)
        .fontSize(12).fontColor(this.isRecording ? '#FFD700' : '#8899AA')
        .margin({ bottom: 6 })
      Button() {
        Stack() {
          if (this.isRecording) {
            Row({ space: 6 }) {
              Image($r('app.media.startIcon')).width(20).height(20).fillColor('#FFFFFF')
              Text('停止').fontSize(14).fontColor('#FFFFFF')
            }
          } else {
            Row({ space: 6 }) {
              Image($r('app.media.startIcon')).width(20).height(20).fillColor('#FFFFFF')
              Text('按住说话').fontSize(14).fontColor('#FFFFFF')
            }
          }
        }
      }
      .width(180).height(44).borderRadius(22)
      .backgroundColor(this.isRecording ? '#FF4D4F' : '#4A90E2')
      .shadow({ radius: 6, color: this.isRecording ? '#FF4D4F40' : '#4A90E240', offsetY: 3 })
      .onClick(() => { this.toggleRecording(); })
    }
    .width('100%').padding({ top: 8, bottom: 12 }).alignItems(HorizontalAlign.Center)
  }
}