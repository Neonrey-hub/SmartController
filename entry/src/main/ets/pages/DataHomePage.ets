// entry/src/main/ets/pages/DataHomePage.ets
import { EdgeDataQuality } from '../components/sensor/EdgeDataQuality'
import { IndustrialSensorCard, SensorItem } from '../components/sensor/IndustrialSensorCard'
import { TrendChartCard } from './TrendChartCard'
import { AlarmQueue, AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting, setting, ApiResponse, data_array } from "ets/network/get_data"
import { generateAlarms } from '../utils/AlarmUtils'
import { AppColors } from '../constants/AppColors'
import { AppDimensions } from '../constants/AppDimensions'

// 模拟传感器数据项接口
interface SimSensorItem {
  tag: string
  value: number
  unit: string
  scale: number
}

const SIM_TAGS = ['二氧化碳', 'PM2.5', 'PM10', '总挥发物', '温度', '湿度', '甲醛', '一氧化碳', '臭氧', '噪声']
const SIM_UNITS = ['ppm', 'μg/m³', 'μg/m³', 'mg/m³', '℃', '%RH', 'mg/m³', 'ppm', 'ppm', 'dB']
const SIM_SCALES = [1, 1, 1, 0.001, 1, 1, 0.001, 1, 1, 1]
const SIM_MIN = [450, 5, 10, 0.05, 16, 30, 0.01, 0, 0, 35]
const SIM_MAX = [1200, 120, 180, 1.8, 32, 75, 0.9, 8, 0.6, 78]

@ComponentV2
export struct DataHomePage {
  @Local data_source: setting = data_setting
  @Local comfortScore: number = 50
  @Local co2Value: string = '--'
  @Local tempValue: string = '--'
  @Local humValue: data_array = this.data_source.get_data.sensor.pretty[6] //湿度
  @Local noiseValue: string = '--'
  @Local alarmItems: AlarmItem[] = []
  @Local abnormalCount: number = 0
  private timerId: number = -1

  aboutToAppear() {
    this.updateAllValues()
    this.updateAlarms()
    this.timerId = setInterval(() => {
      this.updateAllValues()
      this.updateAlarms()
    }, 1000)
  }

  aboutToDisappear() {
    clearInterval(this.timerId)
  }

  private getSensorValue(tag: string): number | undefined {
    const pretty = this.data_source.get_data?.sensor?.pretty
    if (!pretty) {
      return undefined
    }
    const item = pretty.find(s => s.tag === tag)
    return item ? item.value : undefined
  }

  private updateAllValues(): void {
    const co2 = this.getSensorValue('二氧化碳')
    const temp = this.getSensorValue('温度')
    const hum = this.getSensorValue('湿度')
    const noise = this.getSensorValue('噪声')

    // this.co2Value = co2 !== undefined ? co2.toFixed(0) : '--'
    // this.tempValue = temp !== undefined ? temp.toFixed(1) : '--'
    // this.humValue = hum !== undefined ? hum.toFixed(1) : '--'
    // this.noiseValue = noise !== undefined ? noise.toFixed(1) : '--'

    const co2Score = co2 !== undefined ? Math.max(0, Math.min(100, 100 - (co2 - 450) / 8.5)) : 50
    const tempScore = temp !== undefined ? Math.max(0, Math.min(100, 100 - Math.abs(temp - 24) * 7.5)) : 50
    const humScore = hum !== undefined ? Math.max(0, Math.min(100, 100 - Math.abs(hum - 50) * 2.4)) : 50
    const noiseScore = noise !== undefined ? Math.max(0, Math.min(100, 100 - (noise - 35) * 2.2)) : 50

    let raw = Math.round(co2Score * 0.42 + tempScore * 0.22 + humScore * 0.2 + noiseScore * 0.16)
    const penalty = this.abnormalCount * 5
    raw = Math.max(0, raw - penalty)

    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.comfortScore = raw
    })
  }

  private updateAlarms(): void {
    const sensorItems = this.getSensorItems()
    this.alarmItems = generateAlarms(sensorItems)
    this.abnormalCount = this.alarmItems.length
  }

  private getSensorItems(): SensorItem[] {
    const pretty = this.data_source.get_data?.sensor?.pretty || []
    const items: SensorItem[] = []
    for (const s of pretty) {
      items.push({ name: s.tag, value: s.value.toFixed(2), unit: s.unit })
    }
    return items
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('数据')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .width('100%').height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(AppColors.HEADER_BG)

        Scroll() {
          Column({ space: AppDimensions.SPACING_LG }) {
            // ========== 综合工况指数（新布局，不改数据代码） ==========
            Column() {
              // 标题区
              Column({ space: 4 }) {
                Text('综合工况指数')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)
                Text('工业环境主指标')
                  .fontSize(11)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 8, top: 8, bottom: 8 })

              Row({ space: 8 }) {
                // 左侧：CO₂ 和 湿度
                Column({ space: 12 }) {
                  // CO₂卡片（二氧化碳，索引0）
                  Column() {
                    Text('CO₂')
                      .fontSize(12)
                      .fontColor('#86B9D2')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                    Text(this.data_source.get_data.sensor.pretty[0]?.value?.toFixed(0) ?? '--')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#E9FBFF')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 4 })
                    Text('ppm')
                      .fontSize(10)
                      .fontColor('#6FA6C0')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor('rgba(8, 33, 63, 0.8)')
                  .borderRadius(12)
                  .border({ width: 1, color: 'rgba(92, 210, 255, 0.25)' })

                  // 湿度卡片（索引4）
                  Column() {
                    Text('湿度')
                      .fontSize(12)
                      .fontColor('#86B9D2')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                    Text(this.data_source.get_data.sensor.pretty[4]?.value?.toFixed(2) ?? '--')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#E9FBFF')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 4 })
                    Text('%RH')
                      .fontSize(10)
                      .fontColor('#6FA6C0')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor('rgba(8, 33, 63, 0.8)')
                  .borderRadius(12)
                  .border({ width: 1, color: 'rgba(92, 210, 255, 0.25)' })
                }
                .layoutWeight(1)

                // 中间圆环
                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: this.comfortScore, total: 100, type: ProgressType.Ring })
                    .backgroundColor('rgba(26, 48, 80, 0.6)')
                    .style({ strokeWidth: 14 })
                    .width(160)
                    .height(160)
                  Column() {
                    Text(`${this.comfortScore}`)
                      .fontSize(42)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#DDF8FF')
                    Text('舒适指数')
                      .fontSize(12)
                      .fontColor('#86B8CF')
                  }
                  .width(100).height(100).borderRadius(50)
                  .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                  .backgroundColor('rgba(13, 34, 60, 0.9)')
                }
                .layoutWeight(1.2)

                // 右侧：温度和噪声
                Column({ space: 12 }) {
                  // 温度卡片（索引5）
                  Column() {
                    Text('温度')
                      .fontSize(12)
                      .fontColor('#86B9D2')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                    Text(this.data_source.get_data.sensor.pretty[5]?.value?.toFixed(2) ?? '--')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#E9FBFF')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 4 })
                    Text('℃')
                      .fontSize(10)
                      .fontColor('#6FA6C0')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor('rgba(8, 33, 63, 0.8)')
                  .borderRadius(12)
                  .border({ width: 1, color: 'rgba(92, 210, 255, 0.25)' })

                  // 噪声卡片（索引9）
                  Column() {
                    Text('噪声')
                      .fontSize(12)
                      .fontColor('#86B9D2')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                    Text(this.data_source.get_data.sensor.pretty[9]?.value?.toFixed(2) ?? '--')
                      .fontSize(24)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#E9FBFF')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 4 })
                    Text('dB')
                      .fontSize(10)
                      .fontColor('#6FA6C0')
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .padding({ top: 12, bottom: 12 })
                  .backgroundColor('rgba(8, 33, 63, 0.8)')
                  .borderRadius(12)
                  .border({ width: 1, color: 'rgba(92, 210, 255, 0.25)' })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 8, right: 8, bottom: 16 })
            }
            .width('100%')
            .borderRadius(20)
            .backgroundColor('rgba(18, 30, 58, 0.8)')
            .border({ width: 1, color: 'rgba(0, 229, 255, 0.25)' })
            .shadow({ radius: 20, color: 'rgba(0, 229, 255, 0.1)', offsetY: 8 })

            // IndustrialSensorCard({ sensorItems: this.data_source.get_data.sensor.pretty })
            List({ space: AppDimensions.SPACING_SM }) {
              ListItem() {
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
              }

              ForEach(this.data_source.get_data.sensor.pretty, (item: data_array) => {
                ListItem() {
                  Row() {
                    // 传感器名称
                    Text(item.tag)
                      .fontSize(AppDimensions.FONT_SIZE_SM)
                      .fontColor(AppColors.TEXT_TERTIARY)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)


                    // 数值 + 单位
                    Row({ space: 39 }) {
                      Text(item.value.toFixed(2).toString())
                        .fontSize(AppDimensions.FONT_SIZE_XL)
                        .fontColor(AppColors.TEXT_PRIMARY)
                        .fontWeight(FontWeight.Bold)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width("70%")
                        .textAlign(TextAlign.Start)
                        .offset({ x: "60%" })


                      Text(item.unit)
                        .fontSize(AppDimensions.FONT_SIZE_XS)
                        .fontColor(AppColors.TEXT_DISABLED)
                        .maxLines(1)
                    }
                    .layoutWeight(1)
                    .justifyContent(FlexAlign.Start)
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
              })
            }
            .width('100%')
            .padding(AppDimensions.SPACING_LG)
            .backgroundColor(AppColors.CARD_BG)
            .borderRadius(AppDimensions.RADIUS_LG)

            // .width('100%')
            // .borderRadius(16)
            // .backgroundColor('rgba(18, 30, 58, 0.7)')
            // .border({ width: 1, color: 'rgba(0, 229, 255, 0.2)' })
            // .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.4)', offsetY: 4 })

            // TrendChartCard()
            //   .width('100%')

            EdgeDataQuality({ abnormalCount: this.abnormalCount })
              .width('100%')
              .borderRadius(16)
              .backgroundColor('rgba(18, 30, 58, 0.7)')
              .border({ width: 1, color: 'rgba(0, 229, 255, 0.2)' })
              .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.4)', offsetY: 4 })

            // AlarmQueue({ alarmItems: this.alarmItems })
            //   .width('100%')
            //   .layoutWeight(1)
            //   .borderRadius(16)
            //   .backgroundColor('rgba(18, 30, 58, 0.7)')
            //   .border({ width: 1, color: 'rgba(255, 91, 110, 0.3)' })
            //   .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.4)', offsetY: 4 })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 32
          })
          .backgroundColor(AppColors.PRIMARY_BG)
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%').height('100%')
      .backgroundColor(AppColors.SECONDARY_BG)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (ExitConfirmManager.handleBackPress()) {
        promptAction.showToast({ message: '再按一次退出应用', duration: 2000, bottom: 500 });
        return true;
      }
      return false;
    })
  }

  @Builder
  buildSideCard(label: string, value: string, unit: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#86B9D2')
        .width('100%')
        .textAlign(TextAlign.Center)
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E9FBFF')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 2 })
      Text(unit)
        .fontSize(10)
        .fontColor('#6FA6C0')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('rgba(8, 33, 63, 0.8)')
    .borderRadius(10)
    .border({ width: 1, color: 'rgba(92, 210, 255, 0.25)' })
  }
}