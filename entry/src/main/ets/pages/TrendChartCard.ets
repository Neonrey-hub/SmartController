// entry/src/main/ets/pages/TrendChartCard.ets

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

interface LegendItem {
  name: string
  color: string
}

@ComponentV2
export struct TrendChartCard {
  // 历史数据队列
  private co2History: number[] = []
  private tempHistory: number[] = []
  private humHistory: number[] = []
  private noiseHistory: number[] = []
  // 每个点对应的时间标签队列（存储格式化字符串）
  private timeLabels: string[] = []

  // 画布尺寸
  private readonly canvasWidth: number = 340
  private readonly canvasHeight: number = 240
  private readonly padLeft: number = 55
  private readonly padRight: number = 45
  private readonly padTop: number = 10
  private readonly padBottom: number = 40   // 留出底部时间标签的空间

  // 稳定上下文
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  // 坐标范围
  private readonly leftMax: number = 1200
  private readonly leftMin: number = 0
  private readonly rightMax: number = 80
  private readonly rightMin: number = 0
  private readonly leftLabels: number[] = [1200, 1000, 800, 600, 400, 200, 0]
  private readonly rightLabels: number[] = [80, 60, 40, 20, 0]

  // 模拟数据
  private simCo2: number = 600
  private simTemp: number = 22
  private simHum: number = 60
  private simNoise: number = 50

  private timerId: number = -1
  @Local refreshFlag: number = 0

  aboutToAppear(): void {
    // 填充初始12个点及其时间标签
    for (let i = 0; i < 12; i++) {
      this.addMockPoint()
    }
    this.timerId = setInterval(() => {
      this.addMockPoint()
      this.refreshFlag++
    }, 1000)
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }

  /** 生成一个新数据点并记录当前时间 */
  private addMockPoint(): void {
    this.simCo2 = this.clamp(this.simCo2 + (Math.random() - 0.5) * 15, 400, 1200)
    this.simTemp = this.clamp(this.simTemp + (Math.random() - 0.5) * 0.3, 16, 32)
    this.simHum = this.clamp(this.simHum + (Math.random() - 0.5) * 1.0, 30, 75)
    this.simNoise = this.clamp(this.simNoise + (Math.random() - 0.5) * 0.8, 35, 78)

    this.co2History.push(this.simCo2)
    this.tempHistory.push(this.simTemp)
    this.humHistory.push(this.simHum)
    this.noiseHistory.push(this.simNoise)

    // 生成时间标签：HH:mm
    const now = new Date()
    const hh = now.getHours().toString().padStart(2, '0')
    const mm = now.getMinutes().toString().padStart(2, '0')
    this.timeLabels.push(`${hh}:${mm}`)

    // 保持队列长度为12
    if (this.co2History.length > 12) {
      this.co2History.shift()
      this.tempHistory.shift()
      this.humHistory.shift()
      this.noiseHistory.shift()
      this.timeLabels.shift()
    }
  }

  private clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value))
  }

  private getSeriesList(): TrendSeriesItem[] {
    return [
      { name: 'CO₂', color: '#20E5FF', axis: 'left', values: this.co2History },
      { name: '温度', color: '#2BE8C2', axis: 'right', values: this.tempHistory },
      { name: '湿度', color: '#F4C84F', axis: 'right', values: this.humHistory },
      { name: '噪声', color: '#FF5A76', axis: 'right', values: this.noiseHistory }
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
    const ctx = this.ctx
    if (!ctx) return
    if (this.co2History.length < 2) return

    const width = this.canvasWidth
    const height = this.canvasHeight
    ctx.clearRect(0, 0, width, height)

    const left = this.padLeft
    const right = width - this.padRight
    const top = this.padTop
    const bottom = height - this.padBottom
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
    ctx.font = '9px sans-serif'
    ctx.fillStyle = '#5D839C'
    ctx.strokeStyle = 'rgba(26, 68, 104, 0.6)'
    ctx.lineWidth = 0.8

    for (let i = 0; i < this.leftLabels.length; i++) {
      const y = top + (plotHeight / (this.leftLabels.length - 1)) * i
      ctx.beginPath()
      ctx.moveTo(left, y)
      ctx.lineTo(right, y)
      ctx.stroke()
      ctx.fillText(this.leftLabels[i].toString(), left - 6, y)
    }

    // 右轴标签
    ctx.textAlign = 'left'
    for (let i = 0; i < this.rightLabels.length; i++) {
      const y = top + (plotHeight / (this.rightLabels.length - 1)) * i
      ctx.fillText(this.rightLabels[i].toString(), right + 6, y)
    }

    // 边框
    ctx.strokeStyle = 'rgba(45, 93, 133, 0.8)'
    ctx.lineWidth = 1.0
    ctx.beginPath()
    ctx.moveTo(left, top)
    ctx.lineTo(left, bottom)
    ctx.lineTo(right, bottom)
    ctx.lineTo(right, top)
    ctx.stroke()

    // 绘制曲线
    const seriesList = this.getSeriesList()
    for (const series of seriesList) {
      this.drawSeries(ctx, series, left, top, plotWidth, plotHeight)
    }

    // 绘制图例（右上角）
    this.drawLegend(ctx, right - 3, top + 8)

    // 绘制横轴时间标签（底部）
    this.drawTimeLabels(ctx, left, bottom, plotWidth)
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
    fillGradient.addColorStop(0, series.color + '30')
    fillGradient.addColorStop(1, series.color + '00')
    ctx.fillStyle = fillGradient
    ctx.fill()

    // 折线
    ctx.beginPath()
    ctx.strokeStyle = series.color
    ctx.lineWidth = 2.0
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.moveTo(points[0].x, points[0].y)
    for (let i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].y)
    }
    ctx.stroke()

    // 数据点
    for (const p of points) {
      ctx.beginPath()
      ctx.arc(p.x, p.y, 2.5, 0, 2 * Math.PI)
      ctx.fillStyle = series.color
      ctx.fill()
    }
  }

  private drawLegend(ctx: CanvasRenderingContext2D, startX: number, startY: number): void {
    const items: LegendItem[] = [
      { name: 'CO₂', color: '#20E5FF' },
      { name: '温度', color: '#2BE8C2' },
      { name: '湿度', color: '#F4C84F' },
      { name: '噪声', color: '#FF5A76' }
    ]
    ctx.font = '9px sans-serif'
    ctx.textBaseline = 'middle'
    let y = startY + 10
    const x = startX - 45
    for (const item of items) {
      ctx.fillStyle = item.color
      ctx.fillRect(x, y - 1, 10, 3)
      ctx.fillStyle = '#B0C4D8'
      ctx.textAlign = 'left'
      ctx.fillText(item.name, x + 13, y)
      y += 14
    }
  }

  /** 绘制横轴时间标签 */
  private drawTimeLabels(ctx: CanvasRenderingContext2D, plotLeft: number, plotBottom: number, plotWidth: number): void {
    const labels = this.timeLabels
    if (labels.length < 2) return

    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.font = '9px sans-serif'
    ctx.fillStyle = '#7B93A8'

    const segment = plotWidth / (labels.length - 1)
    // 每隔一个点绘制一个标签，避免重叠
    for (let i = 0; i < labels.length; i += 1) {
      const x = plotLeft + segment * i
      ctx.fillText(labels[i], x, plotBottom + 2)
    }
  }

  build() {
    Column() {
      Row() {
        Text('关键指标趋势')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E0E6F0')
        Blank()
        Text('实时趋势 · 12点滚动')
          .fontSize(11)
          .fontColor('#5D6D7E')
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 4 })
      .alignItems(VerticalAlign.Center)

      Stack() {
        Canvas(this.ctx)
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .onReady(() => {
            this.drawChart()
          })
      }
      .width(this.canvasWidth)
      .height(this.canvasHeight)
    }
    .width(this.canvasWidth + 24)
    .borderRadius(16)
    .backgroundColor('rgba(18, 30, 58, 0.75)')
    .border({ width: 1, color: 'rgba(0, 229, 255, 0.25)' })
    .shadow({ radius: 14, color: 'rgba(0, 0, 0, 0.45)', offsetY: 6 })
    .padding({ bottom: 8 })
    .alignItems(HorizontalAlign.Center)
  }
}