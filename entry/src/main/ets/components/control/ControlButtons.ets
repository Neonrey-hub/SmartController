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
      this.ControlButton('展示模式', this.selectedButton === ButtonType.DISPLAY, ButtonType.DISPLAY)
      this.ControlButton('告警模式', this.selectedButton === ButtonType.ALARM, ButtonType.ALARM)
      this.ControlButton('静音模式', this.selectedButton === ButtonType.MUTE, ButtonType.MUTE)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  ControlButton(text: string, isSelected: boolean, type: ButtonType) {
    Text(text)
      .fontSize(AppDimensions.FONT_SIZE_SM)
      .fontColor(isSelected ? AppColors.TEXT_PRIMARY : AppColors.BUTTON_TEXT)
      .fontWeight(isSelected ? FontWeight.Medium : FontWeight.Normal)
      .padding({ left: AppDimensions.SPACING_MD, right: AppDimensions.SPACING_MD, top: 12, bottom: 12 })
      .backgroundColor(isSelected ? AppColors.BUTTON_HOVER : AppColors.BUTTON_NORMAL)
      .borderRadius(AppDimensions.RADIUS_MD)
      .borderWidth(1)
      .borderColor(isSelected ? AppColors.INFO : AppColors.BUTTON_BORDER)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .height(44)
      .onClick(() => {
        console.log('ControlButton onClick triggered for type:', type);
        if (this.onButtonClick) {
          console.log('Calling onButtonClick callback');
          this.onButtonClick(type);
        } else {
          console.log('onButtonClick callback is undefined');
        }
      })
  }
}