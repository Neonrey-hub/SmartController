/**
 * 控制模式枚举
 */
export enum ControlMode {
  /** 场景模式 */
  SCENE = '场景',
  /** 开关模式 */
  SWITCH = '开关',
  /** 模拟量模式 */
  ANALOG = '模拟量'
}

/**
 * 按钮类型枚举
 */
export enum ButtonType {
  /** 展示模式 */
  DISPLAY = 'display',
  /** 告警模式 */
  ALARM = 'alarm',
  /** 静音模式 */
  MUTE = 'mute'
}

/**
 * 控制状态数据模型
 */
export class ControlState {
  /** 当前控制模式 */
  controlMode: ControlMode = ControlMode.SCENE;
  /** 当前选中的按钮 */
  selectedButton: ButtonType = ButtonType.DISPLAY;
  /** 蜂鸣器状态 */
  buzzerEnabled: boolean = false;
  /** 绿灯状态 */
  greenLightEnabled: boolean = false;
  /** 黄灯状态 */
  yellowLightEnabled: boolean = false;
  /** 红灯状态 */
  redLightEnabled: boolean = false;
  /** 小灯亮度值 (0-100) */
  smallLightBrightness: number = 51;
  /** 风扇转速值 (0-100) */
  fanSpeed: number = 53;

  constructor() {
    this.controlMode = ControlMode.SCENE;
    this.selectedButton = ButtonType.DISPLAY;
    this.buzzerEnabled = false;
    this.greenLightEnabled = false;
    this.yellowLightEnabled = false;
    this.redLightEnabled = false;
    this.smallLightBrightness = 51;
    this.fanSpeed = 53;
  }
}