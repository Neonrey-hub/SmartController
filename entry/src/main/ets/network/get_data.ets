import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';

// 根接口返回类型
export interface ApiResponse{
  "success": boolean,
  "meta":meta,
  "sensor":sensor,
  "actuators":actuators
}

export interface meta {
  "updated_at": string,
  "sensor_revision": number,
  "control_revision": number,
  "state_file": string,
  "runtime": string
}

export interface sensor{
  "online": boolean,
  "values": number[],
  "pretty": data_array[]
  /*
   *{"tag": "二氧化碳", "value": 447.0, "unit": "ppm", "scale": 1},
    {"tag": "TVOC总挥发物", "value": 0.114, "unit": "mg/m³", "scale": 0.001},
    {"tag": "甲醛", "value": 0.049, "unit": "mg/m³", "scale": 0.001},
    {"tag": "PM2.5", "value": 5.0, "unit": "μg/m³", "scale": 1},
    {"tag": "湿度", "value": 69.6, "unit": "%RH", "scale": 0.015},
    {"tag": "温度", "value": 19.752, "unit": "℃", "scale": 0.008},
    {"tag": "PM10", "value": 5.0, "unit": "μg/m³", "scale": 1},
    {"tag": "PM1.0", "value": 4.0, "unit": "μg/m³", "scale": 1},
    {"tag": "光照度", "value": 416.0, "unit": "Lux", "scale": 1},
    {"tag": "噪声", "value": 33.88, "unit": "dB", "scale": 0.01}*/
  "updated_at": "2026-04-29T06:54:07.843355+00:00", "last_source": "real-bridge"
}

export interface data_array{
  "tag": string,
  "value": number,
  "unit": string,
  "scale": number
}

export interface actuators{
  "coils": coils,
  "coil_labels":coil_labels,
  "brightness_percent": number,
  "fan_percent": number,
  "updated_at": string,
  "last_source": string
}

export interface coils{
  "buzzer": boolean,
  "green": boolean,
  "yellow": boolean,
  "red": boolean
}
export interface coil_labels{
  "buzzer": string,
  "green": string,
  "yellow": string,
  "red": string
}

@ObservedV2
export class setting{
  // 定时器（类内部私有）
  private timerId: number | null = null;

  //模拟数据
  @Trace get_data:ApiResponse = {"success": true, "meta": {"updated_at": "2026-04-29T06:54:07.850050+00:00", "sensor_revision": 363331, "control_revision": 874, "state_file": "/opt/demo-real/modbus_real_state.json", "runtime": "real-device"}, "sensor": {"online": true, "values": [447.0, 0.114, 0.049, 5.0, 69.6, 19.752, 5.0, 4.0, 416.0, 33.88], "pretty": [{"tag": "二氧化碳", "value": 447.0, "unit": "ppm", "scale": 1}, {"tag": "TVOC总挥发物", "value": 0.114, "unit": "mg/m³", "scale": 0.001}, {"tag": "甲醛", "value": 0.049, "unit": "mg/m³", "scale": 0.001}, {"tag": "PM2.5", "value": 5.0, "unit": "μg/m³", "scale": 1}, {"tag": "湿度", "value": 69.6, "unit": "%RH", "scale": 0.015}, {"tag": "温度", "value": 19.752, "unit": "℃", "scale": 0.008}, {"tag": "PM10", "value": 5.0, "unit": "μg/m³", "scale": 1}, {"tag": "PM1.0", "value": 4.0, "unit": "μg/m³", "scale": 1}, {"tag": "光照度", "value": 416.0, "unit": "Lux", "scale": 1}, {"tag": "噪声", "value": 33.88, "unit": "dB", "scale": 0.01}], "updated_at": "2026-04-29T06:54:07.843355+00:00", "last_source": "real-bridge"}, "actuators": {"coils": {"buzzer": false, "green": false, "yellow": false, "red": false}, "coil_labels": {"buzzer": "蜂鸣器", "green": "绿灯", "yellow": "黄灯", "red": "红灯"}, "brightness_percent": 0.0, "fan_percent": 0.0, "updated_at": "2026-04-29T06:54:07.850025+00:00", "last_source": "real-bridge-readback"}}
  constructor(){
    this.startAutoSend()
  }

  startAutoSend() {
    // 防止重复启动
    if (this.timerId) return;

    console.log("类内部启动每秒自动发送");

    // 核心：每隔 1 秒执行一次请求
    this.timerId = setInterval(() => {
      this.fetchSensorData();
    }, 1000);
  }
  async fetchSensorData(): Promise<ApiResponse | null> {
    // 替换成你的真实接口地址
    const url = "http://10.241.148.11:8090/api/status";

    try {
      const httpRequest = http.createHttp();

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        // 强转成你定义的类型（关键！）
        this.get_data = JSON.parse(response.result as string) as ApiResponse;
        return this.get_data;
      } else {
        console.error("请求失败，状态码：", response.responseCode);
        return null;
      }

    } catch (err) {
      console.error("请求异常：", (err as BusinessError).message);
      return null;
    }
  }

  destroy() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }
}
export const data_setting:setting = new setting()

