import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 指标卡片组件
 * 用于展示单个指标项的标题、数值和辅助说明
 */
@Component
export struct MetricCard {
  /** 指标标题 */
  @Prop title: string = '';
  /** 指标数值 */
  @Prop value: string = '';
  /** 辅助说明文字 */
  @Prop subtitle: string = '';

  build() {
    Column({ space: AppDimensions.SPACING_XS }) {
      Text(this.title)
        .fontSize(AppDimensions.FONT_SIZE_XS)
        .fontColor(AppColors.TEXT_TERTIARY)
        .width('100%')

      Text(this.value)
        .fontSize(AppDimensions.FONT_SIZE_XL)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text(this.subtitle)
        .fontSize(AppDimensions.FONT_SIZE_XS)
        .fontColor(AppColors.TEXT_DISABLED)
        .width('100%')
    }
    .padding(AppDimensions.SPACING_MD)
    .backgroundColor('#0D1B2A')
    .borderRadius(AppDimensions.RADIUS_MD)
    .alignItems(HorizontalAlign.Start)
  }
}
