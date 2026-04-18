import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 状态指示器组件
 * 用于显示蜂鸣器、绿灯、黄灯、红灯等状态
 */
@Component
export struct StatusIndicator {
  /** 指示器名称 */
  @Prop name: string = '';
  /** 是否启用 */
  @Prop isEnabled: boolean = false;
  /** 状态颜色 */
  @Prop color: string = AppColors.TEXT_DISABLED;
  /** 状态切换回调 */
  onToggle?: (enabled: boolean) => void;

  build() {
    Row({ space: AppDimensions.SPACING_SM }) {
      // 状态指示灯
      Circle()
        .width(12)
        .height(12)
        .fill(this.isEnabled ? this.color : AppColors.TEXT_DISABLED)
        .opacity(this.isEnabled ? 1 : 0.3)

      // 状态名称
      Text(this.name)
        .fontSize(AppDimensions.FONT_SIZE_SM)
        .fontColor(this.isEnabled ? AppColors.TEXT_PRIMARY : AppColors.TEXT_TERTIARY)
    }
    .padding({ left: AppDimensions.SPACING_SM, right: AppDimensions.SPACING_SM, top: 8, bottom: 8 })
    .backgroundColor(this.isEnabled ? 'rgba(52, 152, 219, 0.1)' : 'transparent')
    .borderRadius(AppDimensions.RADIUS_MD)
    .borderWidth(1)
    .borderColor(this.isEnabled ? AppColors.INFO : AppColors.DIVIDER)
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle(!this.isEnabled);
      }
    })
  }
}