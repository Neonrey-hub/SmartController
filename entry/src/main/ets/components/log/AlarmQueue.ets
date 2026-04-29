import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 告警等级枚举
 */
export enum AlarmLevel {
  /** 严重告警 - 红色 */
  CRITICAL = 'critical',
  /** 警告 - 橙色 */
  WARNING = 'warning',
  /** 提示 - 蓝色 */
  INFO = 'info'
}

/**
 * 告警队列条目数据结构
 */
export interface AlarmItem {
  /** 告警唯一 ID */
  id: string;
  /** 告警内容描述，如 "温度 越界 31.88 ℃" */
  message: string;
  /** 告警等级，决定左边框颜色 */
  level: AlarmLevel;
}

/**
 * 工业告警队列组件
 * 展示数值触发与联动事件的告警列表
 */
@Component
export struct AlarmQueue {
  /** 告警条目列表 */
  alarmItems: AlarmItem[] = [];

  /**
   * 根据告警等级返回对应颜色
   */
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
      // 标题行
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

      // 告警内容区
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
