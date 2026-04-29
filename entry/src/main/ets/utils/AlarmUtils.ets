// entry/src/main/ets/utils/AlarmUtils.ets
import { SensorItem } from '../components/sensor/IndustrialSensorCard'
import { AlarmItem, AlarmLevel } from '../components/log/AlarmQueue'

/** 告警规则条目 */
interface AlarmRuleItem {
  warn?: number
  err?: number
  warnLow?: number
  warnHigh?: number
  errLow?: number
  errHigh?: number
}

/**
 * 根据传感器列表生成告警条目
 */
export function generateAlarms(sensorItems: SensorItem[]): AlarmItem[] {
  const alarms: AlarmItem[] = []
  let id = 0

  sensorItems.forEach(item => {
    const value = parseFloat(item.value)
    const name = item.name
    const unit = item.unit

    // 定义告警规则映射
    const ruleMap = new Map<string, AlarmRuleItem>([
      ['二氧化碳', { warn: 900, err: 1100 }],
      ['PM2.5', { warn: 50, err: 80 }],
      ['PM10', { warn: 100, err: 150 }],
      ['总挥发物', { warn: 1.2, err: 1.6 }],
      ['温度', { warnLow: 18, warnHigh: 28, errLow: 16, errHigh: 30 }],
      ['湿度', { warnLow: 35, warnHigh: 70, errLow: 30, errHigh: 75 }],
      ['甲醛', { warn: 0.08, err: 0.15 }],
      ['一氧化碳', { warn: 3, err: 6 }],
      ['臭氧', { warn: 0.2, err: 0.35 }],
      ['噪声', { warn: 65, err: 72 }]
    ])

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
      alarms.push({ id: `${id++}`, message, level })
    }
  })

  // 按严重程度排序，最多取2条
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
  return alarms.slice(0, 2)
}