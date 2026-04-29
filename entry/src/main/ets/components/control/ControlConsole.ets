// entry/src/main/ets/components/control/ControlConsole.ets
import { ControlState, ButtonType } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { ControlButtons } from './ControlButtons'
import { StatusIndicator } from './StatusIndicator'
import { ControlSlider } from './ControlSlider'
import { network_connect } from "ets/pages/network_connect";

@Component
export struct ControlConsole {
  @State controlState: ControlState = new ControlState();
  @State selectedButton: ButtonType = ButtonType.DISPLAY;
  onStateChange?: (state: ControlState) => void;

  aboutToAppear() { this.selectedButton = this.controlState.selectedButton; }

  build() {
    Column({ space: AppDimensions.SPACING_LG }) {
      Text('设备联动控制台').fontSize(18).fontWeight(FontWeight.Bold).fontColor(AppColors.TEXT_SECONDARY)
      ControlButtons({ selectedButton: this.selectedButton, onButtonClick: (type: ButtonType) => { this.handleButtonClicked(type); } })

      Row({ space: 8 }) {
        StatusIndicator({ name: '蜂鸣器', isEnabled: this.controlState.buzzerEnabled, color: AppColors.ERROR,
          onToggle: (enabled: boolean) => { this.controlState.buzzerEnabled = enabled; network_connect.send(enabled ? '打开蜂鸣器' : '关闭蜂鸣器'); }})
        StatusIndicator({ name: '绿灯', isEnabled: this.controlState.greenLightEnabled, color: AppColors.SUCCESS,
          onToggle: (enabled: boolean) => { this.controlState.greenLightEnabled = enabled; network_connect.send(enabled ? '打开绿灯' : '关闭绿灯'); }})
      }.width('100%')
      Row({ space: 8 }) {
        StatusIndicator({ name: '黄灯', isEnabled: this.controlState.yellowLightEnabled, color: AppColors.WARNING,
          onToggle: (enabled: boolean) => { this.controlState.yellowLightEnabled = enabled; network_connect.send(enabled ? '打开黄灯' : '关闭黄灯'); }})
        StatusIndicator({ name: '红灯', isEnabled: this.controlState.redLightEnabled, color: AppColors.ERROR,
          onToggle: (enabled: boolean) => { this.controlState.redLightEnabled = enabled; network_connect.send(enabled ? '打开红灯' : '关闭红灯'); }})
      }.width('100%')

      Divider().color('#2D3E50').strokeWidth(1)

      ControlSlider({ label: '小灯亮度', value: this.controlState.smallLightBrightness,
        onValueChange: (value: number) => { this.controlState.smallLightBrightness = value; } })
      ControlSlider({ label: '风扇转速', value: this.controlState.fanSpeed,
        onValueChange: (value: number) => { this.controlState.fanSpeed = value; } })
    }
    .width('100%').padding(20).backgroundColor('#121E3A').borderRadius(20).shadow({ radius: 12, color: '#00000050', offsetY: 4 })
  }

  private handleButtonClicked(type: ButtonType): void { this.selectedButton = type; this.controlState.selectedButton = type; if (this.onStateChange) this.onStateChange(this.controlState); }
}