import { ControlMode } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 控制台标签页组件
 * 用于切换不同的控制模式（场景/开关/模拟量）
 */
@Component
export struct ControlTabs {
  /** 当前选中的模式 */
  @Prop currentMode: ControlMode = ControlMode.SCENE;
  /** 模式切换回调 */
  onModeChange?: (mode: ControlMode) => void;

  build() {
    Row({ space: AppDimensions.SPACING_MD }) {
      this.TabItem(ControlMode.SCENE, this.currentMode === ControlMode.SCENE)
      this.TabItem(ControlMode.SWITCH, this.currentMode === ControlMode.SWITCH)
      this.TabItem(ControlMode.ANALOG, this.currentMode === ControlMode.ANALOG)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  TabItem(mode: ControlMode, isSelected: boolean) {
    Text(mode)
      .fontSize(AppDimensions.FONT_SIZE_SM)
      .fontColor(isSelected ? AppColors.TEXT_PRIMARY : AppColors.TEXT_TERTIARY)
      .fontWeight(isSelected ? FontWeight.Medium : FontWeight.Normal)
      .padding({ left: AppDimensions.SPACING_MD, right: AppDimensions.SPACING_MD, top: 6, bottom: 6 })
      .backgroundColor(isSelected ? AppColors.BUTTON_NORMAL : 'transparent')
      .borderRadius(AppDimensions.RADIUS_MD)
      .onClick(() => {
        if (this.onModeChange) {
          this.onModeChange(mode);
        }
      })
  }
}