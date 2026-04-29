// entry/src/main/ets/components/log/AlarmQueue.ets
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

export enum AlarmLevel {
  CRITICAL = 'critical',
  WARNING = 'warning',
  INFO = 'info'
}

export interface AlarmItem {
  id: string;
  message: string;
  level: AlarmLevel;
}

@ComponentV2
export struct AlarmQueue {
  @Param alarmItems: AlarmItem[] = [];

  private getLevelColor(level: AlarmLevel): string {
    if (level === AlarmLevel.CRITICAL) {
      return AppColors.ERROR;
    } else if (level === AlarmLevel.WARNING) {
      return AppColors.WARNING;
    } else {
      return AppColors.INFO;
    }
  }

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      Row() {
        Text('工业告警队列')
          .fontSize(AppDimensions.FONT_SIZE_MD)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_SECONDARY)

        Text('数值触发与联动事件')
          .fontSize(AppDimensions.FONT_SIZE_XS)
          .fontColor(AppColors.TEXT_DISABLED)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Column({ space: AppDimensions.SPACING_SM }) {
        if (this.alarmItems.length === 0) {
          Text('暂无告警')
            .fontSize(AppDimensions.FONT_SIZE_SM)
            .fontColor(AppColors.TEXT_DISABLED)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: AppDimensions.SPACING_MD, bottom: AppDimensions.SPACING_MD })
        } else {
          ForEach(this.alarmItems, (item: AlarmItem) => {
            Row() {
              Text(item.message)
                .fontSize(AppDimensions.FONT_SIZE_SM)
                .fontColor(AppColors.TEXT_TERTIARY)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({
              left: AppDimensions.SPACING_MD,
              right: AppDimensions.SPACING_MD,
              top: AppDimensions.SPACING_SM,
              bottom: AppDimensions.SPACING_SM
            })
            .backgroundColor('#0D1B2A')
            .borderRadius(AppDimensions.RADIUS_SM)
            .border({ width: { left: 3 }, color: this.getLevelColor(item.level), style: BorderStyle.Solid })
          }, (item: AlarmItem) => item.id)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppDimensions.SPACING_LG)
    .backgroundColor(AppColors.CARD_BG)
    .borderRadius(AppDimensions.RADIUS_LG)
  }
}