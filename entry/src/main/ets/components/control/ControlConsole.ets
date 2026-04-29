import { ControlState, ControlMode, ButtonType, controlState } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { ControlButtons } from './ControlButtons'
import { StatusIndicator } from './StatusIndicator'
import { ControlSlider } from './ControlSlider'
import { network_connect } from "ets/network/network_connect";
import { curb_hardware } from "ets/network/API_risc";
import { data_setting,setting } from "ets/network/get_data";
import { cryptoFramework } from '@kit.CryptoArchitectureKit'

/**
 * 设备联动控制台主容器组件
 * 整合了所有控制台子组件，提供完整的设备控制功能
 */
@ComponentV2
export struct ControlConsole {
  @Local data_setting:setting = data_setting
  /** 控制状态 - 从父组件传入 */
  @Local controlState: ControlState =  controlState;
  /** 当前选中的按钮类型 - 独立状态以确保UI正确更新 */
  @Local selectedButton: ButtonType = ButtonType.DISPLAY;
  /** 状态变化回调 */
  @Local isstatus:number[] = [0,0,0,0]
  onStateChange?: (state: ControlState) => void;

  aboutToAppear() {
    // 初始化 selectedButton 与 controlState 同步
    this.selectedButton = this.controlState.selectedButton;
  }

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 标题栏
      Row() {
        Text('设备联动控制台')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 控制按钮组
      ControlButtons({
        selectedButton: this.selectedButton,
        onButtonClick: (type: ButtonType) => {
          this.handleButtonClicked(type);
        }
      })

      // 状态指示器组
      Row({ space: AppDimensions.SPACING_MD }) {
        StatusIndicator({
          name: '蜂鸣器',
          isEnabled: (this.isstatus[0] == 0 ? data_setting.get_data.actuators.coils.buzzer : this.controlState.buzzerEnabled),
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.isstatus[0] = 1
            if (enabled) {
              curb_hardware.check_buzzer(true)
              // network_connect.send("打开蜂鸣器")
            }else {
              curb_hardware.check_buzzer(false)
              // network_connect.send("关闭蜂鸣器")
            }
            this.controlState.buzzerEnabled = enabled;
            this.controlState.actuatorActive = this.controlState.activeDeviceCount;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        StatusIndicator({
          name: '绿灯',
          isEnabled: (this.isstatus[1] == 0 ? data_setting.get_data.actuators.coils.green : this.controlState.greenLightEnabled),
          color: AppColors.SUCCESS,
          onToggle: (enabled: boolean) => {
            this.isstatus[1] = 1
            if (enabled) {
              // network_connect.send("打开绿灯")
              curb_hardware.check_green(true)
            }else {
              // network_connect.send("关闭绿灯")
              curb_hardware.check_green(false)
            }
            data_setting.change_coils_green(enabled)
            this.controlState.greenLightEnabled = enabled;
            this.controlState.actuatorActive = this.controlState.activeDeviceCount;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: AppDimensions.SPACING_MD }) {
        StatusIndicator({
          name: '黄灯',
          isEnabled: (this.isstatus[2] == 0 ? data_setting.get_data.actuators.coils.yellow : this.controlState.yellowLightEnabled),
          color: AppColors.WARNING,
          onToggle: (enabled: boolean) => {
            this.isstatus[2] = 1
            if (enabled) {
              curb_hardware.check_yellow(true)
              // network_connect.send("打开黄灯")
            }else {
              curb_hardware.check_yellow(false)
              // network_connect.send("关闭黄灯")
            }
            this.controlState.yellowLightEnabled = enabled;
            this.controlState.actuatorActive = this.controlState.activeDeviceCount;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        StatusIndicator({
          name: '红灯',
          isEnabled: (this.isstatus[3] == 0 ? data_setting.get_data.actuators.coils.red : this.controlState.redLightEnabled),
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.isstatus[3] = 1
            if (enabled) {
              curb_hardware.check_red(true)
              // network_connect.send("打开红灯")
            }else {
              curb_hardware.check_red(false)
              // network_connect.send("关闭红灯")
            }
            this.controlState.redLightEnabled = enabled;
            this.controlState.actuatorActive = this.controlState.activeDeviceCount;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 滑块控件组
      Column({ space: AppDimensions.SPACING_MD }) {
        ControlSlider({
          label: '小灯亮度',
          value: this.controlState.smallLightBrightness,
          onValueChange: (value: number) => {
            curb_hardware.API_brightness(value)
            this.controlState.change_smallLightBrightness(value);
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        ControlSlider({
          label: '风扇转速',
          value: this.controlState.fanSpeed,
          onValueChange: (value: number) => {
            curb_hardware.API_fan(value)
            this.controlState.fanSpeed = value;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
  }

  /**
   * 处理按钮点击
   */
  private handleButtonClicked(type: ButtonType): void {
    console.log('Button clicked:', type);
    console.log('Before update, selectedButton:', this.selectedButton);

    // 更新独立的 selectedButton 状态
    this.selectedButton = type;

    // 同时更新 controlState 中的 selectedButton
    this.controlState.selectedButton = type;

    // 根据模式执行不同的设备控制逻辑
    switch (type) {
      case ButtonType.DISPLAY:
        this.setDisplayMode();
        break;
      case ButtonType.ALARM:
        this.setAlarmMode();
        break;
      case ButtonType.MUTE:
        this.setMuteMode();
        break;
    }

    console.log('After update, selectedButton:', this.selectedButton);

    if (this.onStateChange) {
      this.onStateChange(this.controlState);
    }
  }

  /**
   * 设置展示模式：开启绿灯、黄灯、红灯
   */
  private setDisplayMode(): void {
    // 开启所有灯光
    this.controlDevice('绿灯', true, (enabled) => {
      this.controlState.greenLightEnabled = enabled;
    });
    this.controlDevice('黄灯', true, (enabled) => {
      this.controlState.yellowLightEnabled = enabled;
    });
    this.controlDevice('红灯', true, (enabled) => {
      this.controlState.redLightEnabled = enabled;
    });
    
    // 关闭蜂鸣器
    this.controlDevice('蜂鸣器', false, (enabled) => {
      this.controlState.buzzerEnabled = enabled;
    });
    
    // 更新激活设备数量
    this.controlState.actuatorActive = this.controlState.activeDeviceCount;
    
    console.log('设置展示模式：开启所有灯光');
  }

  /**
   * 设置告警模式：开启蜂鸣器和红灯，关闭其他设备
   */
  private setAlarmMode(): void {
    // 开启蜂鸣器和红灯
    this.controlDevice('蜂鸣器', true, (enabled) => {
      this.controlState.buzzerEnabled = enabled;
    });
    this.controlDevice('红灯', true, (enabled) => {
      this.controlState.redLightEnabled = enabled;
    });
    
    // 关闭其他设备
    this.controlDevice('绿灯', false, (enabled) => {
      this.controlState.greenLightEnabled = enabled;
    });
    this.controlDevice('黄灯', false, (enabled) => {
      this.controlState.yellowLightEnabled = enabled;
    });
    
    // 更新激活设备数量
    this.controlState.actuatorActive = this.controlState.activeDeviceCount;
    
    console.log('设置告警模式：开启蜂鸣器和红灯');
  }

  /**
   * 设置静音模式：关闭所有灯光和蜂鸣器
   */
  private setMuteMode(): void {
    // 关闭所有设备
    this.controlDevice('蜂鸣器', false, (enabled) => {
      this.controlState.buzzerEnabled = enabled;
    });
    this.controlDevice('绿灯', false, (enabled) => {
      this.controlState.greenLightEnabled = enabled;
    });
    this.controlDevice('黄灯', false, (enabled) => {
      this.controlState.yellowLightEnabled = enabled;
    });
    this.controlDevice('红灯', false, (enabled) => {
      this.controlState.redLightEnabled = enabled;
    });
    
    // 更新激活设备数量
    this.controlState.actuatorActive = this.controlState.activeDeviceCount;
    
    console.log('设置静音模式：关闭所有设备');
  }

  /**
   * 统一设备控制方法
   * @param deviceName 设备名称（用于发送控制指令）
   * @param enabled 目标状态（true=开启，false=关闭）
   * @param updateState 状态更新回调
   */
  private controlDevice(deviceName: string, enabled: boolean, updateState: (enabled: boolean) => void): void {
    const action = enabled ? '打开' : '关闭';
    const command = `${action}${deviceName}`;
    
    // 发送控制指令
    try {
      network_connect.send(command);
      console.log(`发送控制指令: ${command}`);
    } catch (e) {
      console.warn(`发送控制指令失败: ${command}`, e);
    }
    
    // 更新本地状态
    updateState(enabled);
  }
}