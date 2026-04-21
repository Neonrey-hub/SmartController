import { ControlState } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { MetricCard } from './MetricCard'
import { RingChart } from './RingChart'

/**
 * 执行器联动占用组件
 * 展示执行器参数指标、环形图和状态统计
 */
@Component
export struct ActuatorOccupancy {
  /** 控制状态数据 */
  @Prop controlState: ControlState = new ControlState();

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 标题行
      Row() {
        Text('执行器联动占用')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 三列布局：左侧参数 | 中央环形图 | 右侧统计
      Row({ space: AppDimensions.SPACING_MD }) {
        // 左侧：参数指标卡片
        Column({ space: AppDimensions.SPACING_SM }) {
          MetricCard({
            title: '小灯亮度',
            value: `${Math.round(this.controlState.smallLightBrightness)}%`,
            subtitle: '目标值'
          })
          MetricCard({
            title: '风扇转速',
            value: `${Math.round(this.controlState.fanSpeed)}%`,
            subtitle: '目标值'
          })
        }
        .layoutWeight(1)

        // 中央：环形图
        Column() {
          RingChart({
            percentage: this.controlState.linkageRatio,
            chartSize: 120,
            strokeWidth: 14
          })
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        // 右侧：状态统计卡片
        Column({ space: AppDimensions.SPACING_SM }) {
          MetricCard({
            title: '激活执行器',
            value: `${this.controlState.actuatorActive}/${this.controlState.actuatorTotal}`,
            subtitle: '开关数量'
          })
          MetricCard({
            title: '联动占比',
            value: `${Math.round(this.controlState.linkageRatio)}%`,
            subtitle: '当前占用'
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 底部图例
      Row({ space: AppDimensions.SPACING_LG }) {
        Row({ space: AppDimensions.SPACING_XS }) {
          Row()
            .width(12)
            .height(12)
            .borderRadius(2)
            .backgroundColor(AppColors.RING_ACTIVE)
          Text('已激活')
            .fontSize(AppDimensions.FONT_SIZE_XS)
            .fontColor(AppColors.TEXT_TERTIARY)
        }

        Row({ space: AppDimensions.SPACING_XS }) {
          Row()
            .width(12)
            .height(12)
            .borderRadius(2)
            .backgroundColor(AppColors.RING_BG)
          Text('未激活')
            .fontSize(AppDimensions.FONT_SIZE_XS)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
  }
}
