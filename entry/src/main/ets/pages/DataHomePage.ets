// entry/src/main/ets/pages/DataHomePage.ets
import { EdgeDataQuality } from '../components/sensor/EdgeDataQuality'
import { SensorItem } from '../components/sensor/IndustrialSensorCard'
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting, setting, data_array } from "ets/network/get_data"
import { generateAlarms } from '../utils/AlarmUtils'
import { AppColors } from '../constants/AppColors'
import { AppDimensions } from '../constants/AppDimensions'
import { AlarmQueue, AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'

@ComponentV2
export struct DataHomePage {
  @Local data_source: setting = data_setting
  @Local comfortScore: number = 50
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
    if (!pretty) return undefined
    const item = pretty.find(s => s.tag === tag)
    return item ? item.value : undefined
  }

  private updateAllValues(): void {
    const co2 = this.getSensorValue('二氧化碳')
    const temp = this.getSensorValue('温度')
    const hum = this.getSensorValue('湿度')
    const noise = this.getSensorValue('噪声')

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
      items.push({ name: s.tag, value: s.value.toFixed(1), unit: s.unit })
    }
    return items
  }

  private getCo2Display(): string {
    const v = this.getSensorValue('二氧化碳')
    return v !== undefined ? v.toFixed(0) : '--'
  }
  private getTempDisplay(): string {
    const v = this.getSensorValue('温度')
    return v !== undefined ? v.toFixed(1) : '--'
  }
  private getHumDisplay(): string {
    const v = this.getSensorValue('湿度')
    return v !== undefined ? v.toFixed(1) : '--'
  }
  private getNoiseDisplay(): string {
    const v = this.getSensorValue('噪声')
    return v !== undefined ? v.toFixed(1) : '--'
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
            // 综合工况指数
            Column() {
              Row({ space: 8 }) {
                Column({ space: 8 }) {
                  this.buildSideCard('CO₂', this.getCo2Display(), 'ppm')
                  this.buildSideCard('温度', this.getTempDisplay(), '℃')
                }
                .layoutWeight(1)

                Stack({ alignContent: Alignment.Center }) {
                  Progress({ value: this.comfortScore, total: 100, type: ProgressType.Ring })
                    .backgroundColor('rgba(26, 48, 80, 0.6)')
                    .style({ strokeWidth: 14 })
                    .width(180)
                    .height(180)

                  Column() {
                    Text(`${this.comfortScore}`)
                      .fontSize(48)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#DDF8FF')
                    Text('舒适指数')
                      .fontSize(14)
                      .fontColor('#86B8CF')
                  }
                  .width(120)
                  .height(120)
                  .borderRadius(60)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor('rgba(13, 34, 60, 0.9)')
                  .shadow({ radius: 12, color: 'rgba(56, 189, 248, 0.2)', offsetY: 4 })
                }
                .layoutWeight(1.5)

                Column({ space: 8 }) {
                  this.buildSideCard('湿度', this.getHumDisplay(), '%RH')
                  this.buildSideCard('噪声', this.getNoiseDisplay(), 'dB')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
            }
            .width('100%')
            .borderRadius(20)
            .backgroundColor('rgba(18, 30, 58, 0.8)')
            .border({ width: 1, color: 'rgba(0, 229, 255, 0.25)' })
            .shadow({ radius: 20, color: 'rgba(0, 229, 255, 0.1)', offsetY: 8 })

            // 工业现场十合一传感器（数据已由 get_data 层保证完整且顺序正确）
            Column() {
              Row() {
                Text('工业现场十合一传感器')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ddf7ff')
                Text('边缘实时采集与状态感知')
                  .fontSize(13)
                  .fontColor('#6d98b2')
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Grid() {
                ForEach(this.data_source.get_data.sensor.pretty, (item: data_array) => {
                  GridItem() {
                    Column() {
                      Text(item.tag)
                        .fontSize(14)
                        .fontColor('#93c7df')
                        .margin({ bottom: 6 })
                      Row({ space: 4 }) {
                        Text(item.value.toFixed(1))
                          .fontSize(24)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#ebfbff')
                        Text(item.unit)
                          .fontSize(13)
                          .fontColor('#6fa6c0')
                          .alignSelf(ItemAlign.End)
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.Start)
                      .alignItems(VerticalAlign.Bottom)
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('rgba(8,34,66,0.86)')
                    .borderRadius(10)
                    .border({ width: 1, color: 'rgba(95,227,255,0.2)' })
                    .alignItems(HorizontalAlign.Start)
                  }
                }, (item: data_array) => item.tag)
              }
              .columnsTemplate('1fr 1fr')
              .rowsGap(10)
              .columnsGap(10)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('rgba(18,30,58,0.8)')
            .borderRadius(16)
            .border({ width: 1, color: 'rgba(0,229,255,0.25)' })

            // 边缘数据质量
            EdgeDataQuality({ abnormalCount: this.abnormalCount })
              .width('100%')
              .borderRadius(16)
              .backgroundColor('rgba(18, 30, 58, 0.7)')
              .border({ width: 1, color: 'rgba(0, 229, 255, 0.2)' })
              .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.4)', offsetY: 4 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 32 })
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