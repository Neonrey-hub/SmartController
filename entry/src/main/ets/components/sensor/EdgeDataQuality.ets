// entry/src/main/ets/components/sensor/EdgeDataQuality.ets
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

@ComponentV2
export struct EdgeDataQuality {
  @Param abnormalCount: number = 0;

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
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
      .padding({ left: AppDimensions.SPACING_MD, right: AppDimensions.SPACING_MD, top: AppDimensions.SPACING_SM, bottom: AppDimensions.SPACING_SM })
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