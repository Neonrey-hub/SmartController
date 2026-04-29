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

@Component
export struct TrendChartCard {
  // 图表尺寸与边距
  private readonly canvasWidth: number = 340
  private readonly canvasHeight: number = 240
  private readonly paddingLeft: number = 50
  private readonly paddingRight: number = 50
  private readonly paddingTop: number = 20
  private readonly paddingBottom: number = 36

  // 渲染上下文
  private readonly canvasSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private readonly context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings)

  // 左轴 (CO2) 范围
  private readonly leftMax: number = 1200
  private readonly leftMin: number = 0
  // 右轴 (温度/湿度/噪声) 范围
  private readonly rightMax: number = 80
  private readonly rightMin: number = 0

  // 左轴刻度标签
  private readonly leftLabels: number[] = [1200, 1000, 800, 600, 400, 200, 0]
  private readonly rightLabels: number[] = [80, 60, 40, 20, 0]

  // 数据系列（示例数据）
  private readonly seriesList: TrendSeriesItem[] = [
    { name: 'CO₂', color: '#20E5FF', axis: 'left', values: [1080, 1040, 1090, 1060, 1120, 1030, 1040, 1050, 1060, 1065, 1070, 1060] },
    { name: '温度', color: '#2BE8C2', axis: 'right', values: [72, 74, 73, 69, 72, 73, 72, 72, 71, 71, 70, 70] },
    { name: '湿度', color: '#F4C84F', axis: 'right', values: [30, 31, 30, 31, 30, 30, 31, 31, 30, 30, 30, 30] },
    { name: '噪声', color: '#FF5A76', axis: 'right', values: [58, 74, 54, 50, 41, 42, 42, 42, 42, 41, 41, 40] }
  ]

  /** 将数值转换为绘图 y 坐标 */
  private getY(value: number, axis: 'left' | 'right', plotTop: number, plotHeight: number): number {
    if (axis === 'left') {
      return plotTop + ((this.leftMax - value) / (this.leftMax - this.leftMin)) * plotHeight
    } else {
      return plotTop + ((this.rightMax - value) / (this.rightMax - this.rightMin)) * plotHeight
    }
  }

  /** 绘制整个图表 */
  private drawChart(): void {
    const ctx = this.context
    const width = this.canvasWidth
    const height = this.canvasHeight
    ctx.clearRect(0, 0, width, height)

    const left: number = this.paddingLeft
    const right: number = width - this.paddingRight
    const top: number = this.paddingTop
    const bottom: number = height - this.paddingBottom
    const plotWidth: number = right - left
    const plotHeight: number = bottom - top

    // ---- 1. 绘图区背景渐变 ----
    const bgGradient = ctx.createLinearGradient(left, top, left, bottom)
    bgGradient.addColorStop(0, '#04203D')
    bgGradient.addColorStop(1, '#072846')
    ctx.fillStyle = bgGradient
    ctx.fillRect(left, top, plotWidth, plotHeight)

    // ---- 2. 网格线 + 左轴标签 ----
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

    // ---- 3. 右轴标签 ----
    ctx.textAlign = 'left'
    for (let i = 0; i < this.rightLabels.length; i++) {
      const y = top + (plotHeight / (this.rightLabels.length - 1)) * i
      ctx.fillText(this.rightLabels[i].toString(), right + 8, y)
    }

    // ---- 4. 边框线 ----
    ctx.strokeStyle = '#2D5D85'
    ctx.lineWidth = 1.2
    ctx.beginPath()
    ctx.moveTo(left, top)
    ctx.lineTo(left, bottom)
    ctx.lineTo(right, bottom)
    ctx.lineTo(right, top)
    ctx.stroke()

    // ---- 5. 绘制每个系列 ----
    for (const series of this.seriesList) {
      this.drawSeries(ctx, series, left, top, plotWidth, plotHeight)
    }

    // ---- 6. 图例 (右上角) ----
    this.drawLegend(ctx, right - 10, top + 8)
  }

  /** 绘制单条折线（含渐变填充、圆点标记） */
  private drawSeries(ctx: CanvasRenderingContext2D, series: TrendSeriesItem,
    plotLeft: number, plotTop: number, plotWidth: number, plotHeight: number): void {
    if (series.values.length === 0) return

    const vals = series.values
    const segment = plotWidth / (vals.length - 1)

    // 显式声明类型 Point[] 避免对象字面量类型错误
    const points: Point[] = []
    for (let i = 0; i < vals.length; i++) {
      const x = plotLeft + segment * i
      const y = this.getY(vals[i], series.axis, plotTop, plotHeight)
      points.push({ x, y })
    }

    // ---- 5.1 半透明渐变填充区域 ----
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

    // ---- 5.2 折线 ----
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

    // ---- 5.3 数据点标记 ----
    for (const p of points) {
      ctx.beginPath()
      ctx.arc(p.x, p.y, 3.5, 0, 2 * Math.PI)
      ctx.fillStyle = series.color
      ctx.fill()
      ctx.shadowColor = series.color + '80'
      ctx.shadowBlur = 4
      ctx.fill()
      ctx.shadowColor = 'transparent'
      ctx.shadowBlur = 0
    }
  }

  /** 绘制图例（使用标准路径绘制圆角矩形背景） */
  private drawLegend(ctx: CanvasRenderingContext2D, startX: number, startY: number): void {
    const itemHeight = 18
    const spacing = 10
    const itemWidth = 45
    let y = startY + 12

    const legendX = startX - (itemWidth + 20)
    const legendWidth = itemWidth + 20
    const legendHeight = this.seriesList.length * (itemHeight + spacing) + 16

    // 背景填充（圆角矩形手动绘制）
    ctx.beginPath()
    this.drawRoundedRect(ctx, legendX, startY, legendWidth, legendHeight, 4)
    ctx.fillStyle = '#071F36B0'
    ctx.fill()
    ctx.strokeStyle = '#2D5D85'
    ctx.lineWidth = 0.6
    ctx.stroke()

    ctx.font = '10px sans-serif'
    ctx.textBaseline = 'middle'
    for (const series of this.seriesList) {
      // 颜色方块
      ctx.fillStyle = series.color
      ctx.fillRect(legendX + 10, y + 2, 10, 4)
      // 文字
      ctx.fillStyle = '#B0C4D8'
      ctx.textAlign = 'left'
      ctx.fillText(series.name, legendX + 24, y + 4)
      y += itemHeight + spacing
    }
  }

  /** 绘制圆角矩形路径的方法 */
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
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Stack() {
        Canvas(this.context)
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .onReady(() => {
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