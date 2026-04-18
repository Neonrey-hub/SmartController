import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 设备在线状态标签组件
 * 显示设备的在线/离线状态
 */
@Component
export struct DeviceOnlineTag {
  /** 是否在线 */
  @Prop isOnline: boolean = true;

  build() {
    Row({ space: AppDimensions.SPACING_XS }) {
      // 状态指示点
      Circle()
        .width(8)
        .height(8)
        .fill(this.isOnline ? AppColors.SUCCESS : AppColors.TEXT_DISABLED)

      // 状态文字
      Text(this.isOnline ? '在线' : '离线')
        .fontSize(AppDimensions.FONT_SIZE_SM)
        .fontColor(this.isOnline ? AppColors.SUCCESS : AppColors.TEXT_DISABLED)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: AppDimensions.SPACING_SM, right: AppDimensions.SPACING_SM, top: 4, bottom: 4 })
    .backgroundColor(this.isOnline ? 'rgba(46, 204, 113, 0.1)' : 'rgba(93, 109, 126, 0.1)')
    .borderRadius(AppDimensions.RADIUS_SM)
  }
}