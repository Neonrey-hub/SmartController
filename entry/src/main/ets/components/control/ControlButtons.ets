import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { ButtonType } from '../../models/ControlState'

/**
 * 控制按钮组件
 * 用于控制展示模式、告警模式、静音模式等
 * 实现单选功能，只有一个按钮可以处于高亮状态
 */
@Component
export struct ControlButtons {
  /** 当前选中的按钮类型 */
  @Prop selectedButton: ButtonType = ButtonType.DISPLAY;
  /** 按钮点击回调 */
  onButtonClick?: (type: ButtonType) => void;

  build() {
    Row({ space: AppDimensions.SPACING_MD }) {
      this.ControlButton('静音模式', ButtonType.MUTE)
      this.ControlButton('告警模式', ButtonType.ALARM)
      this.ControlButton('展示模式', ButtonType.DISPLAY)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  ControlButton(text: string, type: ButtonType) {
    // 直接读取 this.selectedButton，确保 ArkTS 能正确追踪响应式依赖
    Text(text)
      .fontSize(AppDimensions.FONT_SIZE_SM)
      .fontColor(this.selectedButton === type ? AppColors.TEXT_PRIMARY : AppColors.BUTTON_TEXT)
      .fontWeight(this.selectedButton === type ? FontWeight.Medium : FontWeight.Normal)
      .padding({ left: AppDimensions.SPACING_MD, right: AppDimensions.SPACING_MD, top: 12, bottom: 12 })
      .backgroundColor(this.selectedButton === type ? AppColors.BUTTON_HOVER : AppColors.BUTTON_NORMAL)
      .borderRadius(AppDimensions.RADIUS_MD)
      .borderWidth(1)
      .borderColor(this.selectedButton === type ? AppColors.INFO : AppColors.BUTTON_BORDER)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .height(44)
      .onClick(() => {
        if (this.onButtonClick) {
          this.onButtonClick(type);
        }
      })
  }
}