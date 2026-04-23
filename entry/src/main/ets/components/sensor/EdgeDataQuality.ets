import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 边缘数据质量卡片
 * 展示异常指标数量统计
 */
@Component
export struct EdgeDataQuality {
  /** 异常指标数量 */
  abnormalCount: number = 0;

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 标题行
      Row() {
        Text('边缘数据质量')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 数据展示区
      Column({ space: AppDimensions.SPACING_XS }) {
        Text('异常指标')
          .fontSize(AppDimensions.FONT_SIZE_SM)
          .fontColor(AppColors.TEXT_TERTIARY)
          .width('100%')

        Text(`${this.abnormalCount}`)
          .fontSize(AppDimensions.FONT_SIZE_XXL)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        Text('项')
          .fontSize(AppDimensions.FONT_SIZE_SM)
          .fontColor(AppColors.TEXT_DISABLED)
          .width('100%')
      }
      .width('100%')
      .padding({
        left: AppDimensions.SPACING_MD,
        right: AppDimensions.SPACING_MD,
        top: AppDimensions.SPACING_SM,
        bottom: AppDimensions.SPACING_SM
      })
      .backgroundColor('#0D1B2A')
      .borderRadius(AppDimensions.RADIUS_MD)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
  }
}
