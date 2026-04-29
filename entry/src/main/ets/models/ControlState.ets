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
@ObservedV2
export class ControlState {
  /** 当前控制模式 */
  @Trace controlMode: ControlMode = ControlMode.SCENE;
  /** 当前选中的按钮 */
  @Trace selectedButton: ButtonType = ButtonType.DISPLAY;
  /** 蜂鸣器状态 */
  @Trace buzzerEnabled: boolean = false;
  /** 绿灯状态 */
  @Trace greenLightEnabled: boolean = false;
  /** 黄灯状态 */
  @Trace yellowLightEnabled: boolean = false;
  /** 红灯状态 */
  @Trace redLightEnabled: boolean = false;
  /** 小灯亮度值 (0-100) */
  @Trace smallLightBrightness: number = 51;
  /** 风扇转速值 (0-100) */
  @Trace fanSpeed: number = 53;

  // ---- 执行器联动占用相关字段 ----
  /** 激活的执行器数量 */
  @Trace actuatorActive: number = 0;
  /** 执行器总数 */
  @Trace actuatorTotal: number = 4;
  /** 联动占比 (0-100) */
  @Trace linkageRatio: number = 0;

  change_smallLightBrightness(num:number){
    this.smallLightBrightness = num
    console.log(String(this.smallLightBrightness))
  }

  constructor() {
    this.controlMode = ControlMode.SCENE;
    this.selectedButton = ButtonType.DISPLAY;
    this.buzzerEnabled = false;
    this.greenLightEnabled = false;
    this.yellowLightEnabled = false;
    this.redLightEnabled = false;
    this.smallLightBrightness = 51;
    this.fanSpeed = 53;
    this.actuatorActive = 0;
    this.actuatorTotal = 4;
    this.linkageRatio = 0;
  }
}

export const controlState = new ControlState()