// entry/src/main/ets/pages/DataHomePage.ets
import { IndustrialSensorCard, SensorItem } from '../components/sensor/IndustrialSensorCard'
import { EdgeDataQuality } from '../components/sensor/EdgeDataQuality'
import { TrendChartCard } from './TrendChartCard'
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'


@Component
export struct DataHomePage {
  private readonly comfortScore: number = 45
  private readonly sensorItems: SensorItem[] = [ { name: '二氧化碳', value: '1055.55', unit: 'ppm' } ]

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('数据')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E0E6F0')
        }
        .width('100%').height(56).justifyContent(FlexAlign.Center).backgroundColor('#081F37')

        Scroll() {
          Column({ space: 20 }) {
            Column() {
              Stack({ alignContent: Alignment.Center }) {
                Progress({ value: 100, total: 100, type: ProgressType.Ring })
                  .backgroundColor('#1A3050').style({ strokeWidth: 16 }).width(220).height(220)
                Column() {
                  Text(`${this.comfortScore}`).fontSize(64).fontWeight(FontWeight.Bold).fontColor('#DDF8FF')
                  Text('舒适指数').fontSize(18).fontColor('#86B8CF')
                }
                .width(160).height(160).borderRadius(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor('#0D223C')
                .shadow({ radius: 12, color: '#38BDF820', offsetY: 4 })
              }
              .width('100%').height(300).padding(20)
            }
            .width('100%').borderRadius(24)
            .linearGradient({ angle: 135, colors: [['#0F2540', 0.0], ['#162D50', 1.0]] })
            .shadow({ radius: 16, color: '#00000040', offsetY: 6 })

            Column() {
              Row() {
                Text('关键指标趋势').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#B0C4D8')
                Blank()
                Text('最近12小时').fontSize(12).fontColor('#666')
              }
              .width('100%').padding({ top: 12, left: 16, right: 16 })
              TrendChartCard()
            }
            .width('100%').backgroundColor('#121E3A').borderRadius(20).shadow({ radius: 8, color: '#00000030', offsetY: 3 })

            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Stretch }) {
              IndustrialSensorCard({ sensorItems: this.sensorItems }).layoutWeight(1).margin({ right: 8 })
              EdgeDataQuality({ abnormalCount: 7 }).layoutWeight(1).margin({ left: 8 })
            }
            .width('100%')
          }
          .width('100%').padding({ left: 16, right: 16, top: 16, bottom: 32 }).backgroundColor('#0A1428')
        }
        .layoutWeight(1).width('100%').scrollBar(BarState.Auto).edgeEffect(EdgeEffect.Spring)
      }
      .width('100%').height('100%').backgroundColor('#081F37')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (ExitConfirmManager.handleBackPress()) {
        promptAction.showToast({ message: '再按一次退出应用', duration: 2000, bottom:500 });
        return true;
      }
      return false;
    })
  }
}