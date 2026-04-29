import { DeviceOnlineTag } from './DeviceOnlineTag'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 设备信息卡片组件
 * 显示设备基本信息，包括设备名称、在线状态、更新时间和设备图片
 */
@Component
export struct DeviceInfoCard {
  /** 设备名称 */
  @Prop deviceName: string = '设备名称';
  /** 是否在线 */
  @Prop isOnline: boolean = true;
  /** 更新时间 */
  @Prop updateTime: string = '';

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 设备基本信息行
      Row() {
        // 左侧：设备名称和在线标签
        Column({ space: AppDimensions.SPACING_XS }) {
          // 设备名称
          Text(this.deviceName)
            .fontSize(AppDimensions.FONT_SIZE_XL)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 在线状态标签
          DeviceOnlineTag({ isOnline: this.isOnline })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 右侧：更新时间
        if (this.updateTime) {
          Text(this.updateTime)
            .fontSize(AppDimensions.FONT_SIZE_XS)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 设备图片占位符
      Image($r('app.media.startIcon'))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Contain)
        .borderRadius(AppDimensions.RADIUS_LG)
        .padding(AppDimensions.SPACING_LG)
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
  }
}