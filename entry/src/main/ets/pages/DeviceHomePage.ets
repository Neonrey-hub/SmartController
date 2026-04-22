import { DeviceInfoCard } from '../components/device/DeviceInfoCard'
import { ControlConsole } from '../components/control/ControlConsole'
import { ActuatorOccupancy } from '../components/actuator/ActuatorOccupancy'
import { EventLog, EventLogItem } from '../components/log/EventLog'
import { AlarmQueue, AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'
import { DateUtils } from '../utils/DateUtils'
import { network_connect } from "ets/pages/network_connect";
/**
 * 设备 Tab 主页：承载「设备」导航目标页，用于设备列表、控制面板等
 */
@ComponentV2
export struct DeviceHomePage {
  /** 设备名称 */
  @Local deviceName: string = '设备名称';
  /** 更新时间 */
  @Local updateTime: string = '';
  /** 事件日志列表 */
  @Local logItems: EventLogItem[] = [
    { time: '22:48:55', message: 'DataV 大屏已更新' }
  ];
  /** 告警队列列表 */
  @Local alarmItems: AlarmItem[] = [
    { id: '1', message: '温度 越界 31.88 ℃', level: AlarmLevel.CRITICAL },
    { id: '2', message: '甲醇 过高 0.26 mg/m³', level: AlarmLevel.CRITICAL }
  ];

  aboutToAppear() {
    // 初始化更新时间
    this.updateTime = DateUtils.getCurrentDateTime();
    // 每次进入页面主动检测一次连接状态，WiFi 断开后重连场景下可快速恢复
    network_connect.reconnect();
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
              isOnline: network_connect.state,
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

            // 工业事件日志
            EventLog({ logItems: this.logItems })

            // 工业告警队列
            AlarmQueue({ alarmItems: this.alarmItems })
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
