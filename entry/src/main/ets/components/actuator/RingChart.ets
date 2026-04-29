// entry/src/main/ets/components/actuator/RingChart.ets
import { AppColors } from '../../constants/AppColors'

@ComponentV2
export struct RingChart {
  @Param percentage: number = 0;
  @Param chartSize: number = 120;
  @Param strokeWidth: number = 14;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // 使用 @Monitor 监听 percentage 变化，并触发重绘
  @Monitor('percentage')
  onPercentChanged() {
    this.drawRing();
  }

  build() {
    Canvas(this.context)
      .width(this.chartSize)
      .height(this.chartSize)
      .onReady(() => {
        this.drawRing();
      })
  }

  private drawRing(): void {
    const cx = this.chartSize / 2;
    const cy = this.chartSize / 2;
    const radius = Math.max(1, cx - this.strokeWidth / 2);
    const startAngle = -Math.PI / 2;
    const activeAngle = (this.percentage / 100) * 2 * Math.PI;

    const ctx = this.context;
    ctx.clearRect(0, 0, this.chartSize, this.chartSize);

    // 绘制背景环（未激活）
    ctx.beginPath();
    ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
    ctx.strokeStyle = AppColors.RING_BG;
    ctx.lineWidth = this.strokeWidth;
    ctx.lineCap = 'round';
    ctx.stroke();

    // 绘制激活环
    if (this.percentage > 0) {
      ctx.beginPath();
      ctx.arc(cx, cy, radius, startAngle, startAngle + activeAngle);
      ctx.strokeStyle = AppColors.RING_ACTIVE;
      ctx.lineWidth = this.strokeWidth;
      ctx.lineCap = 'round';
      ctx.stroke();
    }

    // 中心文字
    ctx.fillStyle = AppColors.TEXT_PRIMARY;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.font = '20px sans-serif';
    ctx.fillText(`${Math.round(this.percentage)}%`, cx, cy - 8);
    ctx.font = '10px sans-serif';
    ctx.fillStyle = AppColors.TEXT_TERTIARY;
    ctx.fillText('占用率', cx, cy + 12);
  }
}