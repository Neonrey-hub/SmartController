// entry/src/main/ets/pages/TrendChartCard.ets
import { data_setting } from "ets/network/get_data"

interface TrendSeriesItem {
  name: string
  color: string
  axis: 'left' | 'right'
  values: number[]
}

interface Point {
  x: number
  y: number
}

interface SensorDataItem {
  tag: string
  value: number
}

@ComponentV2
export struct TrendChartCard {
  // 历史数据
  private readonly co2History: number[] = []
  private readonly tempHistory: number[] = []
  private readonly humHistory: number[] = []
  private readonly noiseHistory: number[] = []
  // 画布尺寸
  private canvasWidth: number = 340
  private canvasHeight: number = 240
  private paddingLeft: number = 50
  private paddingRight: number = 50
  private paddingTop: number = 20
  private paddingBottom: number = 36
  private canvasCtx: CanvasRenderingContext2D | null = null
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private leftMax: number = 1200
  private leftMin: number = 0
  private rightMax: number = 80
  private rightMin: number = 0
  private leftLabels: number[] = [1200, 1000, 800, 600, 400, 200, 0]
  private rightLabels: number[] = [80, 60, 40, 20, 0]
  private timerId: number = -1

  aboutToAppear(): void {
    this.startUpdate()
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }

  private startUpdate(): void {
    // 立即执行一次获取初始数据
    this.fetchSensorData()
    this.timerId = setInterval(() => {
      this.fetchSensorData()
      this.drawChart()
    }, 1000)
  }

  private getSensorValue(pretty: SensorDataItem[], tag: string): number {
    const found = pretty.find(item => item.tag === tag)
    return found ? found.value : 0
  }

  private pushValue(queue: number[], value: number): void {
    queue.push(value)
    if (queue.length > 12) {
      queue.shift()
    }
  }

  private fetchSensorData(): void {
    const snap = data_setting.get_data?.sensor?.pretty
    if (!snap || snap.length === 0) return
    const co2 = this.getSensorValue(snap, '二氧化碳')
    const temp = this.getSensorValue(snap, '温度')
    const hum = this.getSensorValue(snap, '湿度')
    const noise = this.getSensorValue(snap, '噪声')
    this.pushValue(this.co2History, co2)
    this.pushValue(this.tempHistory, temp)
    this.pushValue(this.humHistory, hum)
    this.pushValue(this.noiseHistory, noise)
  }

  private getSeriesList(): TrendSeriesItem[] {
    return [
      {
        name: 'CO₂',
        color: '#20E5FF',
        axis: 'left',
        values: this.co2History
      },
      {
        name: '温度',
        color: '#2BE8C2',
        axis: 'right',
        values: this.tempHistory
      },
      {
        name: '湿度',
        color: '#F4C84F',
        axis: 'right',
        values: this.humHistory
      },
      {
        name: '噪声',
        color: '#FF5A76',
        axis: 'right',
        values: this.noiseHistory
      }
    ]
  }

  private getY(value: number, axis: 'left' | 'right', plotTop: number, plotHeight: number): number {
    if (axis === 'left') {
      return plotTop + ((this.leftMax - value) / (this.leftMax - this.leftMin)) * plotHeight
    } else {
      return plotTop + ((this.rightMax - value) / (this.rightMax - this.rightMin)) * plotHeight
    }
  }

  private drawChart(): void {
    const ctx = this.canvasCtx
    if (!ctx) return

    // 如果没有任何数据，不绘制
    if (this.co2History.length === 0 && this.tempHistory.length === 0) return

    const width = this.canvasWidth
    const height = this.canvasHeight
    ctx.clearRect(0, 0, width, height)

    const left = this.paddingLeft
    const right = width - this.paddingRight
    const top = this.paddingTop
    const bottom = height - this.paddingBottom
    const plotWidth = right - left
    const plotHeight = bottom - top

    // 背景
    const bgGradient = ctx.createLinearGradient(left, top, left, bottom)
    bgGradient.addColorStop(0, '#04203D')
    bgGradient.addColorStop(1, '#072846')
    ctx.fillStyle = bgGradient
    ctx.fillRect(left, top, plotWidth, plotHeight)

    // 网格线 + 左轴标签
    ctx.textAlign = 'right'
    ctx.textBaseline = 'middle'
    ctx.font = '10px sans-serif'
    ctx.fillStyle = '#5D839C'
    ctx.strokeStyle = '#1A4468'
    ctx.lineWidth = 0.8

    for (let i = 0; i < this.leftLabels.length; i++) {
      const y = top + (plotHeight / (this.leftLabels.length - 1)) * i
      ctx.beginPath()
      ctx.moveTo(left, y)
      ctx.lineTo(right, y)
      ctx.stroke()
      ctx.fillText(this.leftLabels[i].toString(), left - 8, y)
    }

    // 右轴标签
    ctx.textAlign = 'left'
    for (let i = 0; i < this.rightLabels.length; i++) {
      const y = top + (plotHeight / (this.rightLabels.length - 1)) * i
      ctx.fillText(this.rightLabels[i].toString(), right + 8, y)
    }

    // 边框
    ctx.strokeStyle = '#2D5D85'
    ctx.lineWidth = 1.2
    ctx.beginPath()
    ctx.moveTo(left, top)
    ctx.lineTo(left, bottom)
    ctx.lineTo(right, bottom)
    ctx.lineTo(right, top)
    ctx.stroke()

    // 折线
    const seriesList = this.getSeriesList()
    for (const series of seriesList) {
      this.drawSeries(ctx, series, left, top, plotWidth, plotHeight)
    }

    // 图例
    this.drawLegend(ctx, right - 10, top + 8)
  }

  private drawSeries(ctx: CanvasRenderingContext2D, series: TrendSeriesItem,
    plotLeft: number, plotTop: number, plotWidth: number, plotHeight: number): void {
    const vals = series.values
    if (vals.length < 2) return

    const segment = plotWidth / (vals.length - 1)
    const points: Point[] = []
    for (let i = 0; i < vals.length; i++) {
      const x = plotLeft + segment * i
      const y = this.getY(vals[i], series.axis, plotTop, plotHeight)
      points.push({ x, y })
    }

    // 渐变填充
    ctx.beginPath()
    ctx.moveTo(points[0].x, points[0].y)
    for (let i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y)
    }
    ctx.lineTo(points[points.length - 1].x, plotTop + plotHeight)
    ctx.lineTo(points[0].x, plotTop + plotHeight)
    ctx.closePath()

    const fillGradient = ctx.createLinearGradient(0, plotTop, 0, plotTop + plotHeight)
    fillGradient.addColorStop(0, series.color + '40')
    fillGradient.addColorStop(1, series.color + '00')
    ctx.fillStyle = fillGradient
    ctx.fill()

    // 折线
    ctx.beginPath()
    ctx.strokeStyle = series.color
    ctx.lineWidth = 2.5
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.moveTo(points[0].x, points[0].y)
    for (let i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y)
    }
    ctx.stroke()

    // 圆点
    for (const p of points) {
      ctx.beginPath()
      ctx.arc(p.x, p.y, 3.5, 0, 2 * Math.PI)
      ctx.fillStyle = series.color
      ctx.fill()
    }
  }

  private drawLegend(ctx: CanvasRenderingContext2D, startX: number, startY: number): void {
    const itemHeight = 18
    const spacing = 10
    const itemWidth = 45
    let y = startY + 12

    const legendX = startX - (itemWidth + 20)
    const legendWidth = itemWidth + 20
    const legendHeight = this.getSeriesList().length * (itemHeight + spacing) + 16

    ctx.beginPath()
    this.drawRoundedRect(ctx, legendX, startY, legendWidth, legendHeight, 4)
    ctx.fillStyle = '#071F36B0'
    ctx.fill()
    ctx.strokeStyle = '#2D5D85'
    ctx.lineWidth = 0.6
    ctx.stroke()

    ctx.font = '10px sans-serif'
    ctx.textBaseline = 'middle'
    for (const series of this.getSeriesList()) {
      ctx.fillStyle = series.color
      ctx.fillRect(legendX + 10, y + 2, 10, 4)
      ctx.fillStyle = '#B0C4D8'
      ctx.textAlign = 'left'
      ctx.fillText(series.name, legendX + 24, y + 4)
      y += itemHeight + spacing
    }
  }

  private drawRoundedRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number): void {
    ctx.moveTo(x + r, y)
    ctx.lineTo(x + w - r, y)
    ctx.arcTo(x + w, y, x + w, y + r, r)
    ctx.lineTo(x + w, y + h - r)
    ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
    ctx.lineTo(x + r, y + h)
    ctx.arcTo(x, y + h, x, y + h - r, r)
    ctx.lineTo(x, y + r)
    ctx.arcTo(x, y, x + r, y, r)
    ctx.closePath()
  }

  build() {
    Column() {
      Row() {
        Text('趋势图')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E0E6F0')
        Blank()
        Text('最近12个采样点')
          .fontSize(12)
          .fontColor('#5D6D7E')
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 8
      })
      .alignItems(VerticalAlign.Center)

      Stack() {
        Canvas(new CanvasRenderingContext2D(this.settings))
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .onReady(() => {
            this.canvasCtx = new CanvasRenderingContext2D(this.settings)
            this.drawChart()
          })
      }
      .width(this.canvasWidth)
      .height(this.canvasHeight)
    }
    .width(this.canvasWidth + 32)
    .borderRadius(16)
    .border({ width: 1, color: '#143556' })
    .linearGradient({
      angle: 170,
      colors: [['#04203D', 0], ['#052B4B', 1]]
    })
    .shadow({ radius: 12, color: '#00000040', offsetY: 4 })
    .padding({ bottom: 12 })
    .alignItems(HorizontalAlign.Center)
  }
}