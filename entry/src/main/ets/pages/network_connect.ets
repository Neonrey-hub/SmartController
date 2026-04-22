import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';
import wifiManager from '@ohos.wifiManager';
import { util } from '@kit.ArkTS';
// import { AlertDialog } from '@kit.ArkUI';
// import { audioPlayer } from './media'; // 路径按你的项目修改

interface websocketmessage{
  "type": string,
  "version": number,
  "transport": string,
  "audio_params":Array<string>
  "session_id": string
  "text":string
}

// 用于存储等待响应的 Promise 回调
interface PendingRequest {
  resolve: (value: string) => void;
  reject: (reason?: Error) => void;
}

// 音频参数子接口
interface AudioParams {
  format: string;
  sample_rate: number;
  channels: number;
  frame_duration: number;
}


// features子接口
interface Features {
  mcp: boolean;
}


@ObservedV2
class WebSocket_connect {
  private ws: webSocket.WebSocket | null = null;
  /*公网测试地址*/
  @Trace ip:string = "119.29.15.120:8000"
  //@Trace ip:string = "192.168.5.8:8000";
  @Trace str_arr:Array<string> = []
  @Trace state:boolean = false
  private session_id : String = '';
  private url: string = `ws://${this.ip}/xiaozhi/v1/`;
  // 存储未完成的请求，key 为 requestId
  private pendingRequests: Map<string, PendingRequest> = new Map();
  // 缓存的设备标识，在 connect 时获取并存储
  private deviceMac: string = '';
  private clientUuid: string = '';

  /**
   * 获取设备 MAC（随机化地址）和 UUID，异步处理
   */
  constructor(){
    this.ws = webSocket.createWebSocket();
    this.connect()
    this.send("你好")
  }

  private async getDeviceInfo(): Promise<void> {
    try {
      // 获取 Wi-Fi MAC
      const wifiInfo = await wifiManager.getLinkedInfo();
      this.deviceMac = wifiInfo.macAddress;
      console.info(`Wi-Fi随机MAC: ${this.deviceMac}`);
    } catch (error) {
      console.error('获取MAC失败:', JSON.stringify(error));
      this.deviceMac = '00:00:00:00:00:00'; // 兜底值
    }

    // 生成或获取缓存的 UUID（此处使用每次生成的随机 UUID）
    this.clientUuid = util.generateRandomUUID(true);
    console.info(`Client UUID: ${this.clientUuid}`);
  }

  async connect() {
    try {
      // 1. 先获取设备信息
      await this.getDeviceInfo();

      // 2. 创建 WebSocket 并绑定事件
      // 3. 发起连接，传入正确的 header 值
      this.ws!.connect(this.url, {
        header: {
          // "Authorization": "Bearer 9e12a5d9d8f34d28a2c20919b9496770",
          "Protocol-Version": "1",
          "device-id": this.deviceMac,
          "client-id": this.clientUuid
        }
      }, (err: BusinessError) => {
        if (err) {
          console.error('连接失败:', JSON.stringify(err));
          return;
        }
        console.log('连接请求已发送');

        this.bindEvents();
      });

    } catch (e) {
      console.error('连接初始化失败:', JSON.stringify(e));

    }
  }

  bindEvents() {
    if (!this.ws) return;

    this.ws.on('open', () => {
      console.info('✅ WebSocket 已连接');
      this.state = true
      this.ws!.send("{\n" +
        "    \"type\": \"hello\",\n" +
        "    \"version\": 1,\n" +
        "    \"transport\": \"websocket\",\n" +
        "    \"features\": {\n" +
        "        \"mcp\": true\n" +
        "    },\n" +
        "    \"audio_params\": {\n" +
        "        \"format\": \"pcm\",\n" +
        "        \"sample_rate\": 16000,\n" +
        "        \"channels\": 1,\n" +
        "        \"frame_duration\": 60\n" +
        "    }\n" +
        "}")
    });

    this.ws.on('message', (err, data ) => {
      if (err) {
        console.error('❌ 接收消息出错:', JSON.stringify(err));
        return;
      }

      if (typeof data !== "string") {
        console.log("二进制数据")
        return
      }
      const messageStr = typeof data === 'string'
        ? data
        : new util.TextDecoder('utf-8').decodeWithStream(new Uint8Array(data as ArrayBuffer));

      try {
        let mes = JSON.parse(messageStr) as websocketmessage
        if (mes.session_id != undefined){
          this.session_id = mes.session_id
          console.log(mes.session_id)
        }
        if (mes.type == "tts" && mes.text !== undefined) {
          console.log(mes.text)
          this.str_arr.push(mes.text)
        }else if (mes.type == "hello") {

        }
      }catch (err){

      }
      console.info('📩 收到服务端消息:', messageStr);

    });
    this.ws.on('close', (err, result) => {
      if (err) {
        console.error('关闭错误:', JSON.stringify(err));
      } else {
        this.state = false
        console.info(`🔌 关闭 code=${result.code} reason=${result.reason}`);
      }

      this.pendingRequests.forEach(pending => {
        pending.reject(new Error('WebSocket连接已关闭'));
      });
      this.pendingRequests.clear();
      this.ws = null;
    });

    this.ws.on('error', (err) => {
      console.error('❌ 异常:', JSON.stringify(err));
    });
  }

  send(data: string): Promise<string> {
    return new Promise(async (resolve, reject) => {
      if (!(await this.check_connect())) {
        return
      }
      data = `{
              "type": "listen",
              "state": "detect",
              "text": "${data}"
          }`
      // 生成唯一请求ID（实际项目中可以用 uuid 或时间戳+随机数）
      const requestId = util.generateRandomUUID(false);
      // 构造发送的JSON数据，包含请求ID
      const message = JSON.stringify(data); // 整体类型断言

      // 存储回调
      this.pendingRequests.set(requestId, { resolve, reject });

      // 发送
      this.ws!.send(data, (err) => {
        if (err) {
          // 发送失败，立即从Map中移除并reject
          this.pendingRequests.delete(requestId);
          reject(new Error(`发送失败: ${JSON.stringify(err)}`));
        } else {
          console.info(`✅ 发送成功 (requestId: ${requestId}) 内容: ${data}`);
        }
      });
    });
  }

  async check_connect(): Promise<boolean> {
      for (let index = 0; index <4 ; index++) {
        if (!this.ws) {
          this.connect()
          console.log("debug debug 重连",index+1)
        }else {
          return true
        }
      }
      return false
  }

  close() {
    this.state = false
    if (!this.ws) return;
    this.ws.close({ code: 1000, reason: 'userClose' }, (err) => {
      if (err) console.error('关闭失败:', JSON.stringify(err));
    });
  }

}

export const network_connect = new WebSocket_connect()