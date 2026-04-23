// entry/src/main/ets/managers/AudioCaptureManager.ets
import audio from '@ohos.multimedia.audio';
import { BusinessError } from '@ohos.base';
import { Constants } from '../common/Constants';

export class AudioCaptureManager {
  private audioCapturer: audio.AudioCapturer | undefined;
  private isCapturing: boolean = false;
  private dataCallback: ((data: ArrayBuffer) => void) | undefined;

  async init(): Promise<void> {
    if (this.audioCapturer) return;
    try {
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: Constants.SAMPLE_RATE,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };
      const audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      };
      const options: audio.AudioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: audioCapturerInfo
      };
      this.audioCapturer = await audio.createAudioCapturer(options);
      console.info('[AudioCaptureManager] init success');
    } catch (err) {
      console.error(`[AudioCaptureManager] init failed: ${JSON.stringify(err)}`);
      throw new Error('Failed to create audio capturer');
    }
  }

  start(callback: (data: ArrayBuffer) => void): void {
    if (!this.audioCapturer) return;
    if (this.isCapturing) return;
    this.dataCallback = callback;
    this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
      if (this.isCapturing && this.dataCallback) {
        this.dataCallback(buffer);
      }
    });
    this.audioCapturer.start((err: BusinessError) => {
      if (err) {
        console.error(`[AudioCaptureManager] start failed: ${err.message}`);
        return;
      }
      this.isCapturing = true;
      console.info('[AudioCaptureManager] start success');
    });
  }

  stop(): void {
    if (!this.audioCapturer || !this.isCapturing) return;
    this.audioCapturer.stop((err: BusinessError) => {
      if (err) {
        console.error(`[AudioCaptureManager] stop failed: ${err.message}`);
      } else {
        console.info('[AudioCaptureManager] stop success');
      }
      this.isCapturing = false;
      this.dataCallback = undefined;
    });
  }

  release(): void {
    if (this.audioCapturer) {
      this.audioCapturer.release((err: BusinessError) => {
        if (err) {
          console.error(`[AudioCaptureManager] release failed: ${err.message}`);
        } else {
          console.info('[AudioCaptureManager] release success');
        }
        this.audioCapturer = undefined;
      });
    }
  }
}