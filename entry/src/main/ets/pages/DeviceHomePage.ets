import { DeviceInfoCard } from '../components/device/DeviceInfoCard'
import { ControlConsole } from '../components/control/ControlConsole'
import { ActuatorOccupancy } from '../components/actuator/ActuatorOccupancy'
import { DateUtils } from '../utils/DateUtils'
import { network_connect } from "ets/pages/network_connect";
/**
 * 设备 Tab 主页：承载「设备」导航目标页，用于设备列表、控制面板等
 */
@ComponentV2
export struct DeviceHomePage {
  /** 设备名称 */
  @Local deviceName: string = '设备名称';
  /** 是否在线 */
  @Local isOnline: boolean = network_connect.state;
  /** 更新时间 */
  @Local updateTime: string = '';

  aboutToAppear() {
    // 初始化更新时间
    this.updateTime = DateUtils.getCurrentDateTime();
  }

  build() {
    // 导航子页：与 Index 中 NavPathStack 的 DevicePage 路由名对应
    NavDestination() {
      Column() {
        // 自定义顶栏
        Row() {
          Text($r('app.string.tab_device'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#081F37')

        // 设备页内容区
        Scroll() {
          Column({ space: 12 }) {
            // 设备信息卡片
            DeviceInfoCard({
              deviceName: this.deviceName,
              isOnline: this.isOnline,
              updateTime: this.updateTime
            })

            // 设备联动控制台
            ControlConsole({
              onStateChange: (state) => {
                console.log('控制台状态变化:', state);
              }
            })

            // 执行器联动占用
            ActuatorOccupancy()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 32 })
          .backgroundColor('#0F1626')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#0B1220')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#081F37')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}
