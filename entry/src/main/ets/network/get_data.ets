// entry/src/main/ets/network/get_data.ets
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { API_URL } from "ets/network/API_URL";
import { isnetwork_connect } from "ets/network/isconnect";

// 根接口返回类型
export interface ApiResponse {
  "success": boolean;
  "meta": meta;
  "sensor": sensor;
  "actuators": actuators;
}

export interface meta {
  "updated_at": string;
  "sensor_revision": number;
  "control_revision": number;
  "state_file": string;
  "runtime": string;
}

export interface sensor {
  "online": boolean;
  "values": number[];
  "pretty": data_array[];
  "updated_at": string;
  "last_source": string;
}

export interface data_array {
  "tag": string;
  "value": number;
  "unit": string;
  "scale": number;
}

export interface actuators {
  "coils": coils;
  "coil_labels": coil_labels;
  "brightness_percent": number;
  "fan_percent": number;
  "updated_at": string;
  "last_source": string;
}

export interface coils {
  "buzzer": boolean;
  "green": boolean;
  "yellow": boolean;
  "red": boolean;
}
export interface coil_labels {
  "buzzer": string;
  "green": string;
  "yellow": string;
  "red": string;
}

// 定义默认传感器值的结构
interface SensorDefault {
  value: number;
  unit: string;
  scale: number;
}

// 完整的传感器列表（与 Web UI 顺序一致）
const FULL_SENSOR_TAGS: string[] = [
  '二氧化碳', 'PM2.5', 'PM10', 'TVOC总挥发物', '温度', '湿度', '甲醛', '一氧化碳', '臭氧', '噪声'
];

// 默认传感器值（当后端缺失时使用，数值为合理典型值）
const DEFAULT_SENSOR_VALUES: Record<string, SensorDefault> = {
  '二氧化碳': { value: 450, unit: 'ppm', scale: 1 },
  'PM2.5': { value: 30, unit: 'μg/m³', scale: 1 },
  'PM10': { value: 60, unit: 'μg/m³', scale: 1 },
  'TVOC总挥发物': { value: 0.2, unit: 'mg/m³', scale: 0.001 },
  '温度': { value: 22.0, unit: '℃', scale: 0.008 },
  '湿度': { value: 55.0, unit: '%RH', scale: 0.015 },
  '甲醛': { value: 0.05, unit: 'mg/m³', scale: 0.001 },
  '一氧化碳': { value: 0.5, unit: 'ppm', scale: 1 },
  '臭氧': { value: 0.05, unit: 'ppm', scale: 1 },
  '噪声': { value: 55.0, unit: 'dB', scale: 0.01 }
};

/**
 * 确保传感器数据完整且顺序正确
 * @param rawPretty 后端返回的原始 pretty 数组（可能缺失或乱序）
 * @returns 完整且按固定顺序排列的 pretty 数组
 */
function ensureCompleteSensorData(rawPretty: data_array[] | undefined): data_array[] {
  if (!rawPretty) {
    // 完全无数据，返回全默认值
    return FULL_SENSOR_TAGS.map(tag => {
      const def = DEFAULT_SENSOR_VALUES[tag];
      return {
        tag: tag,
        value: def.value,
        unit: def.unit,
        scale: def.scale
      } as data_array;
    });
  }

  const result: data_array[] = [];
  for (const tag of FULL_SENSOR_TAGS) {
    const found = rawPretty.find(item => item.tag === tag);
    if (found) {
      // 使用后端数据，但确保单位不为空（若为空则用默认单位）
      const defaultUnit = DEFAULT_SENSOR_VALUES[tag]?.unit;
      const unit = (found.unit && found.unit.trim() !== '') ? found.unit : (defaultUnit || '');
      result.push({
        tag: tag,
        value: found.value,
        unit: unit,
        scale: found.scale || DEFAULT_SENSOR_VALUES[tag]?.scale || 1
      });
    } else {
      // 后端缺失，使用默认值
      const def = DEFAULT_SENSOR_VALUES[tag];
      result.push({
        tag: tag,
        value: def.value,
        unit: def.unit,
        scale: def.scale
      });
      console.warn(`[get_data] 传感器 "${tag}" 未从后端获取，使用默认值 ${def.value} ${def.unit}`);
    }
  }
  return result;
}

@ObservedV2
export class setting {
  private timerId: number | null = null;
  @Trace is_running: number = 0;
  @Trace get_data: ApiResponse = {
    "success": true,
    "meta": {
      "updated_at": "2026-04-29T06:54:07.850050+00:00",
      "sensor_revision": 363331,
      "control_revision": 874,
      "state_file": "/opt/demo-real/modbus_real_state.json",
      "runtime": "real-device"
    },
    "sensor": {
      "online": true,
      "values": [447.0, 5.0, 5.0, 0.114, 19.752, 69.6, 0.049, 0.5, 0.05, 33.88],
      "pretty": [
        { "tag": "二氧化碳", "value": 447.0, "unit": "ppm", "scale": 1 },
        { "tag": "PM2.5", "value": 5.0, "unit": "μg/m³", "scale": 1 },
        { "tag": "PM10", "value": 5.0, "unit": "μg/m³", "scale": 1 },
        { "tag": "TVOC总挥发物", "value": 0.114, "unit": "mg/m³", "scale": 0.001 },
        { "tag": "温度", "value": 19.752, "unit": "℃", "scale": 0.008 },
        { "tag": "湿度", "value": 69.6, "unit": "%RH", "scale": 0.015 },
        { "tag": "甲醛", "value": 0.049, "unit": "mg/m³", "scale": 0.001 },
        { "tag": "一氧化碳", "value": 0.5, "unit": "ppm", "scale": 1 },
        { "tag": "臭氧", "value": 0.05, "unit": "ppm", "scale": 1 },
        { "tag": "噪声", "value": 33.88, "unit": "dB", "scale": 0.01 }
      ],
      "updated_at": "2026-04-29T06:54:07.843355+00:00",
      "last_source": "real-bridge"
    },
    "actuators": {
      "coils": { "buzzer": false, "green": false, "yellow": false, "red": false },
      "coil_labels": { "buzzer": "蜂鸣器", "green": "绿灯", "yellow": "黄灯", "red": "红灯" },
      "brightness_percent": 0.0,
      "fan_percent": 0.0,
      "updated_at": "2026-04-29T06:54:07.850025+00:00",
      "last_source": "real-bridge-readback"
    }
  };
  @Trace state = false;

  constructor() {
    this.check_running();
    this.startAutoSend();
  }

  startAutoSend() {
    if (this.timerId) return;
    console.log("类内部启动每秒自动发送");
    this.timerId = setInterval(() => {
      this.fetchSensorData();
      isnetwork_connect();
    }, 1000);
  }

  async fetchSensorData(): Promise<ApiResponse | null> {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(`http://${API_URL}:8090/api/status`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      });
      if (response.responseCode === 200) {
        let rawData = JSON.parse(response.result as string) as ApiResponse;
        // 补全并标准化传感器数据
        rawData.sensor.pretty = ensureCompleteSensorData(rawData.sensor.pretty);
        rawData.sensor.values = rawData.sensor.pretty.map(item => item.value);
        this.get_data = rawData;
        console.log("请求成功，传感器数量:", this.get_data.sensor.pretty.length);
        this.state = true;
        this.check_running();
        return this.get_data;
      } else {
        console.error("请求失败，状态码：", response.responseCode);
        this.state = false;
        return null;
      }
    } catch (err) {
      console.error("请求异常：", (err as BusinessError).message);
      this.state = false;
      return null;
    }
  }

  change_coils_green(isenabled: boolean) {
    this.get_data.actuators.coils.green = isenabled;
  }

  check_running(): number {
    let num = 0;
    const values = Object.values(this.get_data.actuators.coils) as boolean[];
    values.forEach(value => { if (value) num++; });
    this.is_running = num;
    return num;
  }

  destroy() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }
}

export const data_setting: setting = new setting();