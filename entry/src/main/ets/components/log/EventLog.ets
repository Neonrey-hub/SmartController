import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 事件日志条目数据结构
 */
export interface EventLogItem {
  /** 时间戳字符串，如 "22:48:55" */
  time: string;
  /** 事件内容描述 */
  message: string;
}

/**
 * 工业事件日志组件
 * 展示控制回执与系统事件追踪日志列表
 */
@Component
export struct EventLog {
  /** 日志条目列表 */
  logItems: EventLogItem[] = [];

  build() {
    Column({ space: AppDimensions.SPACING_MD }) {
      // 标题行
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

      // 日志内容区
      Column({ space: AppDimensions.SPACING_SM }) {
        if (this.logItems.length === 0) {
          Text('暂无事件日志')
            .fontSize(AppDimensions.FONT_SIZE_SM)
            .fontColor(AppColors.TEXT_DISABLED)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: AppDimensions.SPACING_MD, bottom: AppDimensions.SPACING_MD })
        } else {
          ForEach(this.logItems, (item: EventLogItem) => {
            Row() {
              Text(`[${item.time}] ${item.message}`)
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
            .border({ width: { left: 3 }, color: AppColors.INFO, style: BorderStyle.Solid })
          }, (item: EventLogItem, index: number) => index.toString())
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
