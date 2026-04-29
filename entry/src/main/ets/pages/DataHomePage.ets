// entry/src/main/ets/pages/DataHomePage.ets
import { EdgeDataQuality } from '../components/sensor/EdgeDataQuality'
import { IndustrialSensorCard, SensorItem } from '../components/sensor/IndustrialSensorCard'
import { TrendChartCard } from './TrendChartCard'
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting, setting } from "ets/network/get_data"
import { AppColors } from '../constants/AppColors'
import { AppDimensions } from '../constants/AppDimensions'

@ComponentV2
export struct DataHomePage {
  @Local data_source: setting = data_setting

  /** 将传感器数据转换为 SensorItem 列表 */
  private getSensorItems(): SensorItem[] {
    let items: SensorItem[] = []
    try {
      const sensorData = this.data_source.get_data?.sensor?.pretty
      if (sensorData && sensorData.length) {
        sensorData.forEach(item => {
          items.push({
            name: item.tag,
            value: item.value.toFixed(1),
            unit: item.unit
          })
        })
      }
    } catch (e) {
      console.error('解析传感器数据失败', e)
    }
    return items
  }

  /**
   * 固定算法计算舒适指数 (0-100)
   * 依据：温度、湿度、PM2.5、二氧化碳四项指标
   */
  private calculateComfortScore(): number {
    try {
      const sensors = this.data_source.get_data?.sensor?.pretty
      if (!sensors || sensors.length === 0) return 50 // 无数据时默认50

      // 从 pretty 中提取指定传感器值
      const getValue = (tag: string): number | undefined => {
        const item = sensors.find(s => s.tag === tag)
        return item ? item.value : undefined
      }

      const temp = getValue('温度')
      const humid = getValue('湿度')
      const pm25 = getValue('PM2.5')
      const co2 = getValue('二氧化碳')

      // 各指标得分（0-1）
      const tempScore = temp !== undefined ? Math.max(0, 1 - Math.abs(temp - 25) / 10) : 0.5
      const humidScore = humid !== undefined ? Math.max(0, 1 - Math.abs(humid - 45) / 25) : 0.5
      const pm25Score = pm25 !== undefined ? Math.max(0, 1 - pm25 / 35) : 0.5
      const co2Score = co2 !== undefined ? Math.max(0, 1 - co2 / 1000) : 0.5

      // 加权综合（权重可调）
      const overall = 0.25 * tempScore + 0.25 * humidScore + 0.25 * pm25Score + 0.25 * co2Score
      return Math.round(overall * 100)
    } catch (e) {
      console.error('计算舒适指数失败', e)
      return 45 // 兜底值
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Text('数据')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E0E6F0')
        }
        .width('100%').height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#081F37')

        Scroll() {
          Column({ space: 20 }) {
            // ---- 动态舒适指数环 ----
            Column() {
              Stack({ alignContent: Alignment.Center }) {
                Circle()
                  .width(240).height(240)
                  .fill('#1A3050')
                  .opacity(0.3)

                Progress({ value: 100, total: 100, type: ProgressType.Ring })
                  .backgroundColor('#1A3050')
                  .style({ strokeWidth: 16 })
                  .width(220).height(220)

                Column() {
                  Text(`${this.calculateComfortScore()}`)  // 动态计算
                    .fontSize(64).fontWeight(FontWeight.Bold)
                    .fontColor('#DDF8FF')
                  Text('舒适指数')
                    .fontSize(18).fontColor('#86B8CF')
                }
                .width(160).height(160)
                .borderRadius(80)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor('#0D223C')
                .shadow({ radius: 12, color: '#38BDF820', offsetY: 4 })
              }
              .width('100%').height(300).padding(20)
            }
            .width('100%')
            .borderRadius(24)
            .linearGradient({
              angle: 135,
              colors: [['#0F2540', 0.0], ['#162D50', 1.0]]
            })
            .shadow({ radius: 16, color: '#00000040', offsetY: 6 })

            // 十合一传感器卡片（动态数据）
            IndustrialSensorCard({
              sensorItems: this.getSensorItems()
            })
              .width('100%')

            // 趋势图表卡片
            TrendChartCard()
              .width('100%')

            // 边缘数据质量卡片
            EdgeDataQuality({ abnormalCount: 7 })
              .width('100%')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 32 })
          .backgroundColor('#0A1428')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%').height('100%')
      .backgroundColor('#081F37')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (ExitConfirmManager.handleBackPress()) {
        promptAction.showToast({
          message: '再按一次退出应用',
          duration: 2000,
          bottom: 500
        });
        return true;
      }
      return false;
    })
  }
}