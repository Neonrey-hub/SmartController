import { ControlState, ControlMode, ButtonType } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { ControlButtons } from './ControlButtons'
import { StatusIndicator } from './StatusIndicator'
import { ControlSlider } from './ControlSlider'

/**
 * 设备联动控制台主容器组件
 * 整合了所有控制台子组件，提供完整的设备控制功能
 */
@Component
export struct ControlConsole {
  /** 控制状态 */
  @State controlState: ControlState = new ControlState();
  /** 当前选中的按钮类型 - 独立状态以确保UI正确更新 */
  @State selectedButton: ButtonType = ButtonType.DISPLAY;
  /** 状态变化回调 */
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
      Row({ space: AppDimensions.SPACING_SM }) {
        StatusIndicator({
          name: '蜂鸣器',
          isEnabled: this.controlState.buzzerEnabled,
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.controlState.buzzerEnabled = enabled;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        StatusIndicator({
          name: '绿灯',
          isEnabled: this.controlState.greenLightEnabled,
          color: AppColors.SUCCESS,
          onToggle: (enabled: boolean) => {
            this.controlState.greenLightEnabled = enabled;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
      }
      .width('100%')

      Row({ space: AppDimensions.SPACING_SM }) {
        StatusIndicator({
          name: '黄灯',
          isEnabled: this.controlState.yellowLightEnabled,
          color: AppColors.WARNING,
          onToggle: (enabled: boolean) => {
            this.controlState.yellowLightEnabled = enabled;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        StatusIndicator({
          name: '红灯',
          isEnabled: this.controlState.redLightEnabled,
          color: AppColors.ERROR,
          onToggle: (enabled: boolean) => {
            this.controlState.redLightEnabled = enabled;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
      }
      .width('100%')

      // 滑块控件组
      Column({ space: AppDimensions.SPACING_MD }) {
        ControlSlider({
          label: '小灯亮度',
          value: this.controlState.smallLightBrightness,
          onValueChange: (value: number) => {
            this.controlState.smallLightBrightness = value;
            if (this.onStateChange) {
              this.onStateChange(this.controlState);
            }
          }
        })
        ControlSlider({
          label: '风扇转速',
          value: this.controlState.fanSpeed,
          onValueChange: (value: number) => {
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

    console.log('After update, selectedButton:', this.selectedButton);

    if (this.onStateChange) {
      this.onStateChange(this.controlState);
    }
  }
}