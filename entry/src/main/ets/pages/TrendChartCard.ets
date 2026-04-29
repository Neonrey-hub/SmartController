interface TrendSeriesItem {
  name: string
  color: string
  axis: 'left' | 'right'
  values: number[]
}

@Component
export struct TrendChartCard {
  private readonly canvasWidth: number = 320
  private readonly canvasHeight: number = 196
  private readonly canvasSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private readonly context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings)
  private readonly leftMax: number = 1200
  private readonly rightMax: number = 80
  private readonly leftAxisLabels: number[] = [1200, 1000, 800, 600, 400, 200, 0]
  private readonly seriesList: TrendSeriesItem[] = [
    { name: 'CO2', color: '#20E5FF', axis: 'left', values: [1080, 1040, 1090, 1060, 1120, 1030, 1040, 1050, 1060, 1065, 1070, 1060] },
    { name: '温度', color: '#2BE8C2', axis: 'right', values: [72, 74, 73, 69, 72, 73, 72, 72, 71, 71, 70, 70] },
    { name: '湿度', color: '#F4C84F', axis: 'right', values: [30, 31, 30, 31, 30, 30, 31, 31, 30, 30, 30, 30] },
    { name: '噪声', color: '#FF5A76', axis: 'right', values: [58, 74, 54, 50, 41, 42, 42, 42, 42, 41, 41, 40] }
  ]

  private drawSeries(series: TrendSeriesItem, left: number, top: number, width: number, height: number): void {
    const segment: number = width / (series.values.length - 1)
    this.context.beginPath()
    this.context.lineWidth = 2.5
    this.context.strokeStyle = series.color
    for (let index: number = 0; index < series.values.length; index++) {
      const value: number = series.values[index]
      const x: number = left + segment * index
      const y: number = series.axis === 'left'
        ? top + (this.leftMax - value) / this.leftMax * height
        : top + (this.rightMax - value) / this.rightMax * height
      if (index === 0) {
        this.context.moveTo(x, y)
      } else {
        this.context.lineTo(x, y)
      }
    }
    this.context.stroke()
  }

  private drawChart(): void {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    const left: number = 26
    const right: number = this.canvasWidth - 26
    const top: number = 12
    const bottom: number = this.canvasHeight - 30
    const plotWidth: number = right - left
    const plotHeight: number = bottom - top

    // 绘制背景与网格
    this.context.fillStyle = '#072846'
    this.context.fillRect(left, top, plotWidth, plotHeight)
    this.context.strokeStyle = '#1A4468'
    this.context.lineWidth = 1
    for (let index: number = 0; index < this.leftAxisLabels.length; index++) {
      const y: number = top + (plotHeight / (this.leftAxisLabels.length - 1)) * index
      this.context.beginPath()
      this.context.moveTo(left, y)
      this.context.lineTo(right, y)
      this.context.stroke()
    }

    // 绘制边框线
    this.context.strokeStyle = '#2D5D85'
    this.context.beginPath()
    this.context.moveTo(left, top)
    this.context.lineTo(left, bottom)
    this.context.lineTo(right, bottom)
    this.context.lineTo(right, top)
    this.context.stroke()

    // 绘制4条指标曲线
    for (let index: number = 0; index < this.seriesList.length; index++) {
      const series: TrendSeriesItem = this.seriesList[index]
      this.drawSeries(series, left, top, plotWidth, plotHeight)
    }
  }

  build() {
    Column() {
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
    .width(this.canvasWidth)
    .height(this.canvasHeight)
    .borderRadius(16)
    .border({ width: 1, color: '#143556' })
    .linearGradient({
      angle: 180,
      colors: [['#04203D', 0], ['#052B4B', 1]]
    })
  }
}
