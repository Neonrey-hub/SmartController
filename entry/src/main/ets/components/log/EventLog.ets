// entry/src/main/ets/components/log/EventLog.ets
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

export interface EventLogItem {
  id: string;
  time: string;
  message: string;
}

@ComponentV2
export struct EventLog {
  @Param logItems: EventLogItem[] = [];

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      Row() {
        Text('工业事件日志')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)
        Text('控制回执与系统事件追踪')
          .fontSize(AppDimensions.FONT_SIZE_XS)
          .fontColor(AppColors.TEXT_DISABLED)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Column({ space: AppDimensions.SPACING_SM }) {
        if (this.logItems.length === 0) {
          Text('暂无事件日志')
            .fontSize(AppDimensions.FONT_SIZE_SM)
            .fontColor(AppColors.TEXT_DISABLED)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: AppDimensions.SPACING_MD, bottom: AppDimensions.SPACING_MD })
        } else {
          Scroll() {
            Column({ space: AppDimensions.SPACING_SM }) {
              ForEach(this.logItems, (item: EventLogItem) => {
                Row() {
                  Text(`[${item.time}] ${item.message}`)
                    .fontSize(AppDimensions.FONT_SIZE_SM)
                    .fontColor(AppColors.TEXT_TERTIARY)
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: AppDimensions.SPACING_MD, right: AppDimensions.SPACING_MD, top: AppDimensions.SPACING_SM, bottom: AppDimensions.SPACING_SM })
                .backgroundColor('#0D1B2A')
                .borderRadius(AppDimensions.RADIUS_SM)
                .border({ width: { left: 3 }, color: AppColors.INFO, style: BorderStyle.Solid })
              }, (item: EventLogItem) => item.id)
            }
          }
          .width('100%')
          .height(120)
          .scrollBar(BarState.On)
          .scrollBarColor('#FFFFFF')
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
    .border({ width: 2, color: '#1E3A5F', style: BorderStyle.Solid })
  }
}