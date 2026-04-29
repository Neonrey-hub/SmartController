import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 单个传感器数据项
 */
export interface SensorItem {
  /** 传感器名称，如 "二氧化碳" */
  name: string;
  /** 数值，如 "1055.55" */
  value: string;
  /** 单位，如 "ppm" */
  unit: string;
}

/**
 * 工业现场十合一传感器卡片
 * 展示多路传感器实时数据，标题区带闪电装饰图标
 */
@Component
export struct IndustrialSensorCard {
  /** 传感器数据列表 */
  sensorItems: SensorItem[] = [];

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 标题行
      Row() {
        Text('工业现场十合一传感器')
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

      // 传感器数据列表
      if (this.sensorItems.length === 0) {
        Text('暂无传感器数据')
          .fontSize(AppDimensions.FONT_SIZE_SM)
          .fontColor(AppColors.TEXT_DISABLED)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: AppDimensions.SPACING_MD, bottom: AppDimensions.SPACING_MD })
      } else {
        Column({ space: AppDimensions.SPACING_SM }) {
          ForEach(this.sensorItems, (item: SensorItem) => {
            this.SensorRow(item)
          }, (item: SensorItem, index: number) => index.toString())
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
  }

  /**
   * 单个传感器数据行
   * 名称 | 数值 + 单位
   */
  @Builder
  SensorRow(item: SensorItem) {
    Row() {
      // 传感器名称
      Text(item.name)
        .fontSize(AppDimensions.FONT_SIZE_SM)
        .fontColor(AppColors.TEXT_TERTIARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      // 数值 + 单位
      Row({ space: AppDimensions.SPACING_XS }) {
        Text(item.value)
          .fontSize(AppDimensions.FONT_SIZE_XL)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.unit)
          .fontSize(AppDimensions.FONT_SIZE_XS)
          .fontColor(AppColors.TEXT_DISABLED)
          .maxLines(1)
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Bottom)
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
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
