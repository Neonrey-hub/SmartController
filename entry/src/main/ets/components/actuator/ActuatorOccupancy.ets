// entry/src/main/ets/components/actuator/ActuatorOccupancy.ets
import { ControlState } from '../../models/ControlState'
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'
import { MetricCard } from './MetricCard'
import { RingChart } from './RingChart'

@ComponentV2
export struct ActuatorOccupancy {
  @Param controlState: ControlState = new ControlState();

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      Row() {
        Text('执行器联动占用')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row({ space: AppDimensions.SPACING_MD }) {
        Column({ space: AppDimensions.SPACING_SM }) {
          MetricCard({
            title: '小灯亮度',
            value: `${Math.round(this.controlState.smallLightBrightness)}%`,
            subtitle: '目标值'
          })
          MetricCard({
            title: '风扇转速',
            value: `${Math.round(this.controlState.fanSpeed)}%`,
            subtitle: '当前值'
          })
        }
        .layoutWeight(1)

        Column() {
          RingChart({
            percentage: this.controlState.linkageRatio,
            chartSize: 120,
            strokeWidth: 14
          })
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)

        Column({ space: AppDimensions.SPACING_SM }) {
          MetricCard({
            title: '激活执行器',
            value: `${this.controlState.actuatorActive}/${this.controlState.actuatorTotal}`,
            subtitle: '高亮按钮数'
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