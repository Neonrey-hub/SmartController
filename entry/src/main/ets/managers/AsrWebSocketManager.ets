// entry/src/main/ets/managers/AsrWebSocketManager.ets
import webSocket from '@ohos.net.webSocket';
import util from '@ohos.util';
import { XfyunAuth } from './XfyunAuth';
import { Constants } from '../common/Constants';

// ========== 严格按照讯飞官方示例定义数据结构 ==========
interface AsrCommon {
  app_id: string;
}

interface AsrBusiness {
  language: string;
  domain: string;
  accent: string;
  vad_eos: number;
  dwa: string;
}

interface AsrData {
  status: number;
  format: string;
  encoding: string;
  audio: string;
}

interface AsrStartFrame {
  common: AsrCommon;
  business: AsrBusiness;
  data: AsrData;
}

interface AsrDataFrameData {
  status: number;
  audio: string;
}

interface AsrDataFrame {
  data: AsrDataFrameData;
}

// 结果词条
interface Cw {
  w?: string;
}

interface Ws {
  cw?: Cw[];
}

interface AsrResult {
  sn?: number;
  ws?: Ws[];
  pgs?: string;
  rg?: number[];
}

interface AsrResponseData {
  result?: AsrResult;
  status?: number;
}

interface AsrResponse {
  code: number;
  message: string;
  sid?: string;
  data?: AsrResponseData;
}

interface AsrCallbacks {
  onOpen?: () => void;
  onResult?: (text: string, isFinal: boolean) => void;
  onError?: (error: Error) => void;
  onClose?: () => void;
}

interface WebSocketError extends Error {
  code?: number;
  data?: string;
}

export class AsrWebSocketManager {
  private ws: webSocket.WebSocket | undefined;
  private callbacks: AsrCallbacks = {};
  private isConnected: boolean = false;
  private resultCache: (AsrResult | null)[] = []; // 用于缓存乱序结果

  setCallbacks(callbacks: AsrCallbacks): void {
    this.callbacks = callbacks;
  }

  async connect(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      try {
        const url = XfyunAuth.generateAuthUrl();
        console.info(`[ASR WebSocket] 连接 URL: ${url}`);
        this.ws = webSocket.createWebSocket();

        this.ws.on('open', (err: Error, value: Object) => {
          if (!err) {
            this.isConnected = true;
            this.resultCache = [];
            this.sendStartFrame();
            if (this.callbacks.onOpen) this.callbacks.onOpen();
            resolve();
          } else {
            console.error(`[ASR WebSocket] open 错误: ${JSON.stringify(err)}`);
            reject(new Error(`WebSocket open failed: ${err.message}`));
          }
        });

        this.ws.on('message', (err: Error, value: string | ArrayBuffer) => {
          if (err) {
            console.error(`[ASR WebSocket] message 错误: ${JSON.stringify(err)}`);
            if (this.callbacks.onError) this.callbacks.onError(new Error(`WebSocket message error: ${err.message}`));
            return;
          }
          this.handleMessage(value);
        });

        this.ws.on('error', (err: Error) => {
          const wsErr = err as WebSocketError;
          console.error(`[ASR WebSocket] 错误码: ${wsErr.code}, 数据: ${wsErr.data}`);
          if (this.callbacks.onError) {
            this.callbacks.onError(new Error(`WebSocket 连接错误: ${err.message || '未知错误'}`));
          }
        });

        this.ws.on('close', (err: Error, value: webSocket.CloseResult) => {
          console.info(`[ASR WebSocket] 连接关闭, code=${value.code}, reason=${value.reason}`);
          this.isConnected = false;
          if (this.callbacks.onClose) this.callbacks.onClose();
        });

        this.ws.connect(url, (err: Error, value: boolean) => {
          if (err) {
            reject(new Error(`WebSocket connect failed: ${err.message}`));
          }
        });
      } catch (e) {
        reject(e);
      }
    });
  }

  private sendStartFrame(): void {
    const frame: AsrStartFrame = {
      common: { app_id: Constants.XFYUN_APP_ID },
      business: {
        language: "zh_cn",
        domain: "iat",
        accent: "mandarin",
        vad_eos: 3000,
        dwa: "wpgs"
      },
      data: {
        status: 0,
        format: "audio/L16;rate=16000",
        encoding: "raw",
        audio: ""
      }
    };
    this.send(JSON.stringify(frame));
    console.info('[ASR] 发送开始帧');
  }

  sendAudio(data: ArrayBuffer): void {
    if (!this.isConnected) return;
    const base64Str = this.arrayBufferToBase64(data);
    const frame: AsrDataFrame = {
      data: {
        status: 1,
        audio: base64Str
      }
    };
    this.send(JSON.stringify(frame));
  }

  sendEnd(): void {
    if (!this.isConnected) return;
    const frame: AsrDataFrame = {
      data: {
        status: 2,
        audio: ""
      }
    };
    this.send(JSON.stringify(frame));
    console.info('[ASR] 发送结束帧');
  }

  private send(data: string): void {
    this.ws?.send(data, (err: Error) => {
      if (err) console.error(`[AsrWebSocket] send error: ${err.message}`);
    });
  }

  private handleMessage(data: string | ArrayBuffer): void {
    try {
      let jsonStr: string;
      if (typeof data === 'string') {
        jsonStr = data;
      } else {
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        jsonStr = textDecoder.decodeToString(new Uint8Array(data), { stream: false });
      }
      console.info(`[ASR] 收到消息: ${jsonStr}`);
      const res: AsrResponse = JSON.parse(jsonStr);

      if (res.code !== 0) {
        console.error(`[ASR] 错误: code=${res.code}, message=${res.message}`);
        if (this.callbacks.onError) this.callbacks.onError(new Error(`ASR error: ${res.message}`));
        return;
      }

      // 处理结果（与官方示例完全一致）
      if (res.data && res.data.result) {
        const result = res.data.result;
        // 缓存结果
        if (result.sn !== undefined) {
          this.resultCache[result.sn] = result;
        }
        // 处理动态修正（如果 pgs 为 'rpl'，则清除对应索引）
        if (result.pgs === 'rpl' && result.rg) {
          result.rg.forEach(idx => {
            this.resultCache[idx] = null;
          });
        }

        // 拼接当前已缓存的识别文本
        let text = '';
        this.resultCache.forEach(item => {
          if (item && item.ws) {
            item.ws.forEach(wsItem => {
              if (wsItem.cw) {
                wsItem.cw.forEach(cwItem => {
                  if (cwItem.w) text += cwItem.w;
                });
              }
            });
          }
        });

        const isFinal = (res.data.status === 2);
        console.info(`[ASR] ${isFinal ? '最终' : '中间'}结果: ${text}`);
        if (this.callbacks.onResult) this.callbacks.onResult(text, isFinal);

        if (isFinal) {
          this.disconnect();
        }
      }
    } catch (e) {
      console.error(`[ASR] 解析消息失败: ${JSON.stringify(e)}`);
    }
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close((err: Error) => {
        if (err) console.error(`[AsrWebSocket] close error: ${err.message}`);
      });
      this.ws = undefined;
      this.isConnected = false;
    }
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const uint8Array = new Uint8Array(buffer);
    const base64 = new util.Base64Helper();
    return base64.encodeToStringSync(uint8Array);
  }
}