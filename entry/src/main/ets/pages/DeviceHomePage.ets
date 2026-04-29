// entry/src/main/ets/pages/DeviceHomePage.ets
import { DeviceInfoCard } from '../components/device/DeviceInfoCard'
import { ControlConsole } from '../components/control/ControlConsole'
import { ActuatorOccupancy } from '../components/actuator/ActuatorOccupancy'
import { EventLog, EventLogItem } from '../components/log/EventLog'
import { AlarmQueue, AlarmItem } from '../components/log/AlarmQueue'
import { DateUtils } from '../utils/DateUtils'
import { ControlState, controlState } from '../models/ControlState'
import { network_connect, WebSocket_connect } from "ets/network/network_connect";
import { promptAction } from '@kit.ArkUI'
import { ExitConfirmManager } from '../common/Constants'
import { data_setting } from "ets/network/get_data";
import { generateAlarms } from '../utils/AlarmUtils'
import { SensorItem } from '../components/sensor/IndustrialSensorCard'

@ComponentV2
export struct DeviceHomePage {
  @Local network_connect: WebSocket_connect = network_connect
  @Local deviceName: string = 'SmartController';
  @Local updateTime: string = '';
  @Local logItems: EventLogItem[] = [];
  @Local alarmItems: AlarmItem[] = [];
  @Local controlState: ControlState = controlState;

  private timerId: number = -1;
  private lastLogMessage: string = '';
  private lastLogTime: number = 0;
  private initialized: boolean = false;

  aboutToAppear() {
    if (this.initialized) return;
    this.initialized = true;

    this.updateTime = DateUtils.getCurrentDateTime();
    network_connect.reconnect();
    this.addLog('DataV 大屏已更新');
    this.startAlarmAndLogUpdate();
  }

  aboutToDisappear() {
    clearInterval(this.timerId);
  }

  private startAlarmAndLogUpdate(): void {
    this.timerId = setInterval(() => {
      this.updateTime = DateUtils.getCurrentDateTime();
      const sensorItems: SensorItem[] = this.getSensorItems();
      this.alarmItems = generateAlarms(sensorItems);
    }, 1000);
  }

  private getSensorItems(): SensorItem[] {
    const pretty = data_setting.get_data?.sensor?.pretty;
    if (!pretty) {
      return [];
    }
    const result: SensorItem[] = [];
    for (const item of pretty) {
      result.push({
        name: item.tag,
        value: item.value.toFixed(1),
        unit: item.unit
      })
    }
    return result;
  }

  /** 添加事件日志，自动记录时间 */
  private addLog(message: string): void {
    const now = Date.now();
    // 如果消息与上次完全相同且距上次不到2秒，则忽略
    if (message === this.lastLogMessage && (now - this.lastLogTime) < 2000) {
      return;
    }
    this.lastLogMessage = message;
    this.lastLogTime = now;

    const date = new Date();
    const hh = date.getHours().toString().padStart(2, '0');
    const mm = date.getMinutes().toString().padStart(2, '0');
    const ss = date.getSeconds().toString().padStart(2, '0');
    const time = `${hh}:${mm}:${ss}`;
    const newItem: EventLogItem = { time: time, message: message };
    this.logItems = [newItem, ...this.logItems].slice(0, 20);
  }

  build() {
    NavDestination() {
      Column() {
        Row() { Text('设备').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#E0E6F0') }
        .width('100%').height(56).justifyContent(FlexAlign.Center).backgroundColor('#081F37')

        Scroll() {
          Column({ space: 20 }) {
            DeviceInfoCard({
              deviceName: this.deviceName,
              isOnline: network_connect.state,
              updateTime: this.updateTime
            })

            Column() {
              Row() {
                Text('快捷控制').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#B0C4D8')
                Blank()
                Text(network_connect.state ? '● 在线' : '○ 离线')
                  .fontSize(12).fontColor(network_connect.state ? '#4ADE80' : '#EF4444')
              }
              .width('100%').padding({ top: 12, left: 16, right: 16 })
              ControlConsole({
                controlState: this.controlState,
                onLog: (msg: string) => this.addLog(msg)
              })
            }
            .width('100%').backgroundColor('#121E3A').borderRadius(20).shadow({ radius: 12, color: '#00000040', offsetY: 4 })

            ActuatorOccupancy({ controlState: this.controlState })

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