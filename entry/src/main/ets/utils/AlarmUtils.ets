// entry/src/main/ets/utils/AlarmUtils.ets
import { SensorItem } from '../components/sensor/IndustrialSensorCard'
import { AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'

interface AlarmRuleItem {
  warn?: number
  err?: number
  warnLow?: number
  warnHigh?: number
  errLow?: number
  errHigh?: number
}

export function generateAlarms(sensorItems: SensorItem[]): AlarmItem[] {
  const alarms: AlarmItem[] = []
  let id = 0

  const ruleMap = new Map<string, AlarmRuleItem>([
    ['二氧化碳', { warn: 1000, err: 1500 }],
    ['TVOC总挥发物', { warn: 0.8, err: 1.2 }],
    ['甲醛', { warn: 0.08, err: 0.15 }],
    ['PM2.5', { warn: 75, err: 115 }],
    ['湿度', { warnLow: 30, warnHigh: 75, errLow: 25, errHigh: 85 }],
    ['温度', { warnLow: 18, warnHigh: 30, errLow: 15, errHigh: 35 }],
    ['PM10', { warn: 150, err: 250 }],
    ['PM1.0', { warn: 80, err: 120 }],
    ['光照度', { warn: 1500, err: 1800 }],
    ['噪声', { warn: 70, err: 85 }],
  ]);

  sensorItems.forEach(item => {
    const value = parseFloat(item.value)
    const name = item.name
    const unit = item.unit
    const rule = ruleMap.get(name)
    if (!rule) return

    let level = AlarmLevel.INFO
    let message = `${name} 正常`

    if (rule.err !== undefined) {
      if (value >= rule.err) {
        level = AlarmLevel.CRITICAL
        message = `${name} 过高 ${value} ${unit}`
      } else if (rule.warn !== undefined && value >= rule.warn) {
        level = AlarmLevel.WARNING
        message = `${name} 偏高 ${value} ${unit}`
      }
    } else if (rule.errLow !== undefined && rule.errHigh !== undefined) {
      if (value <= rule.errLow || value >= rule.errHigh) {
        level = AlarmLevel.CRITICAL
        message = `${name} 越界 ${value} ${unit}`
      } else if (rule.warnLow !== undefined && rule.warnHigh !== undefined &&
        (value <= rule.warnLow || value >= rule.warnHigh)) {
        level = AlarmLevel.WARNING
        message = `${name} 偏离 ${value} ${unit}`
      }
    }

    if (level !== AlarmLevel.INFO) {
      alarms.push({ id: `alarm_${id++}`, message, level })
    }
  })

  // 按严重程度排序，最多取5条
  alarms.sort((a, b) => {
    let pa = 0, pb = 0
    if (a.level === AlarmLevel.CRITICAL) pa = 3
    else if (a.level === AlarmLevel.WARNING) pa = 2
    else pa = 1
    if (b.level === AlarmLevel.CRITICAL) pb = 3
    else if (b.level === AlarmLevel.WARNING) pb = 2
    else pb = 1
    return pb - pa
  })
  return alarms.slice(0, 5)
}