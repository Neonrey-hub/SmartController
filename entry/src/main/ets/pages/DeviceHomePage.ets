// entry/src/main/ets/pages/DeviceHomePage.ets
import { DeviceInfoCard } from '../components/device/DeviceInfoCard'
import { ControlConsole } from '../components/control/ControlConsole'
import { ActuatorOccupancy } from '../components/actuator/ActuatorOccupancy'
import { EventLog, EventLogItem } from '../components/log/EventLog'
import { AlarmQueue, AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'
import { DateUtils } from '../utils/DateUtils'
import { network_connect  , WebSocket_connect} from "ets/network/network_connect";
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting , setting} from "ets/network/get_data";

@ComponentV2
export struct DeviceHomePage {
  @Local network_connect:WebSocket_connect = network_connect
  @Local deviceName: string = 'SmartController';
  @Local updateTime: string = '';
  @Local logItems: EventLogItem[] = [ { time: '22:48:55', message: 'DataV 大屏已更新' } ];
  @Local alarmItems: AlarmItem[] = [
    { id: '1', message: '温度 越界 31.88 ℃', level: AlarmLevel.CRITICAL },
    { id: '2', message: '甲醇 过高 0.26 mg/m³', level: AlarmLevel.CRITICAL }
  ];

  aboutToAppear() {
    this.updateTime = DateUtils.getCurrentDateTime();
    network_connect.reconnect();
  }

  build() {
    NavDestination() {
      Column() {
        Row() { Text('设备').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#E0E6F0') }
        .width('100%').height(56).justifyContent(FlexAlign.Center).backgroundColor('#081F37')

        Scroll() {
          Column({ space: 20 }) {
            DeviceInfoCard({ deviceName: this.deviceName, isOnline: network_connect.state, updateTime: this.updateTime })

            Column() {
              Row() {
                Text('快捷控制').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#B0C4D8')
                Blank()
                Text(network_connect.state ? '● 在线' : '○ 离线')
                  .fontSize(12).fontColor(network_connect.state ? '#4ADE80' : '#EF4444')
              }
              .width('100%').padding({ top: 12, left: 16, right: 16 })
              ControlConsole({})
            }
            .width('100%').backgroundColor('#121E3A').borderRadius(20).shadow({ radius: 12, color: '#00000040', offsetY: 4 })

            ActuatorOccupancy()
            EventLog({ logItems: this.logItems })

            Column() {
              AlarmQueue({ alarmItems: this.alarmItems })
            }
            .width('100%').border({ width: 2, color: '#EF444420', style: BorderStyle.Solid }).borderRadius(20).padding(2)
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