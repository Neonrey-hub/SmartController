// entry/src/main/ets/components/control/ControlConsole.ets
import { ControlState, ButtonType } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { ControlButtons } from './ControlButtons'
import { StatusIndicator } from './StatusIndicator'
import { ControlSlider } from './ControlSlider'
import { curb_hardware } from "ets/network/API_risc"
import { data_setting,setting } from "ets/network/get_data";


@ComponentV2
export struct ControlConsole {
  // @Local data_setting:setting = data_setting
  @Param controlState: ControlState = new ControlState();
  @Local selectedButton: ButtonType = this.controlState.selectedButton;
  @Param onLog?: (msg: string) => void = () => {};
  @Local isstatus:number[] = [0,0,0,0]

  aboutToAppear() {
    this.selectedButton = this.controlState.selectedButton;
  }

  private updateActuatorStats(): void {
    this.controlState.actuatorActive = data_setting.check_running();
    this.controlState.linkageRatio = Math.round((this.controlState.actuatorActive / this.controlState.actuatorTotal) * 100);
  }

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      Row() {
        Text('设备联动控制台')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      ControlButtons({
        selectedButton: this.selectedButton,
        onButtonClick: (type: ButtonType) => {
          this.handleButtonClicked(type);
        }
      })

      Row({ space: 48 }) {
        StatusIndicator({
          name: '蜂鸣器',
          isEnabled: (this.isstatus[0] == 0 ? data_setting.get_data.actuators.coils.buzzer : this.controlState.buzzerEnabled),
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.isstatus[0] = 1
            curb_hardware.check_buzzer(enabled);
            this.controlState.buzzerEnabled = enabled;
            this.updateActuatorStats();
            this.onLog?.(`蜂鸣器 ${enabled ? '开启' : '关闭'}`);
          }
        })
        StatusIndicator({
          name: '绿灯',
          isEnabled: (this.isstatus[1] == 0 ? data_setting.get_data.actuators.coils.green : this.controlState.greenLightEnabled),
          color: AppColors.SUCCESS,
          onToggle: (enabled: boolean) => {
            this.isstatus[1] = 1
            curb_hardware.check_green(enabled);
            this.controlState.greenLightEnabled = enabled;
            this.updateActuatorStats();
            this.onLog?.(`绿灯 ${enabled ? '开启' : '关闭'}`);
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 48 }) {
        StatusIndicator({
          name: '黄灯',
          isEnabled: (this.isstatus[2] == 0 ? data_setting.get_data.actuators.coils.yellow : this.controlState.yellowLightEnabled),
          color: AppColors.WARNING,
          onToggle: (enabled: boolean) => {
            this.isstatus[2] = 1
            curb_hardware.check_yellow(enabled);
            this.controlState.yellowLightEnabled = enabled;
            this.updateActuatorStats();
            this.onLog?.(`黄灯 ${enabled ? '开启' : '关闭'}`);
          }
        })
        StatusIndicator({
          name: '红灯',
          isEnabled: (this.isstatus[3] == 0 ? data_setting.get_data.actuators.coils.red : this.controlState.redLightEnabled),
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.isstatus[3] = 1
            curb_hardware.check_red(enabled);
            this.controlState.redLightEnabled = enabled;
            this.updateActuatorStats();
            this.onLog?.(`红灯 ${enabled ? '开启' : '关闭'}`);
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Column({ space: AppDimensions.SPACING_MD }) {
        ControlSlider({
          label: '小灯亮度',
          value: this.controlState.smallLightBrightness,
          onValueChange: (value: number) => {
            if (value !== this.controlState.smallLightBrightness) {
              this.onLog?.(`小灯亮度 设置为 ${Math.round(value)}%`);
            }
            curb_hardware.API_brightness(value);
            this.controlState.change_smallLightBrightness(value);
            this.updateActuatorStats();
          }
        })
        ControlSlider({
          label: '风扇转速',
          value: this.controlState.fanSpeed,
          onValueChange: (value: number) => {
            if (value !== this.controlState.fanSpeed) {
              this.onLog?.(`风扇转速 设置为 ${Math.round(value)}%`);
            }
            curb_hardware.API_fan(value);
            this.controlState.fanSpeed = value;
            this.updateActuatorStats();
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

  private handleButtonClicked(type: ButtonType): void {
    if (this.selectedButton === type) return;
    this.selectedButton = type;
    this.controlState.selectedButton = type;

    switch (type) {
      case ButtonType.DISPLAY:
        this.controlState.buzzerEnabled = false;
        this.controlState.greenLightEnabled = true;
        this.controlState.yellowLightEnabled = true;
        this.controlState.redLightEnabled = true;
        curb_hardware.check_buzzer(false);
        curb_hardware.check_green(true);
        curb_hardware.check_yellow(true);
        curb_hardware.check_red(true);
        this.isstatus = [1,1,1,1]
        this.onLog?.('展示模式已应用');
        break;
      case ButtonType.ALARM:
        this.controlState.buzzerEnabled = true;
        this.controlState.greenLightEnabled = false;
        this.controlState.yellowLightEnabled = false;
        this.controlState.redLightEnabled = true;
        curb_hardware.check_buzzer(true);
        curb_hardware.check_green(false);
        curb_hardware.check_yellow(false);
        curb_hardware.check_red(true);
        this.onLog?.('告警模式已应用');
        this.isstatus = [1,1,1,1]
        break;
      case ButtonType.MUTE:
        this.controlState.buzzerEnabled = false;
        this.controlState.greenLightEnabled = false;
        this.controlState.yellowLightEnabled = false;
        this.controlState.redLightEnabled = false;
        curb_hardware.check_buzzer(false);
        curb_hardware.check_green(false);
        curb_hardware.check_yellow(false);
        curb_hardware.check_red(false);
        this.onLog?.('静音模式已应用');
        this.isstatus = [1,1,1,1]
        break;
    }
    this.updateActuatorStats();
  }
}