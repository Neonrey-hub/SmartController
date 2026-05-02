import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

/**
 * 控制滑块组件
 * 用于调节小灯亮度、风扇转速等模拟量
 */
@Component
export struct ControlSlider {
  /** 滑块标签 */
  @Prop label: string = '';
  /** 当前值 (0-100) */
  @Prop value: number = 0;
  /** 值变化回调（拖动中） */
  onValueChange?: (value: number) => void;
  /** 值变化结束回调（松开滑块时） */
  onChangeEnd?: (value: number) => void;

  build() {
    Row({ space: AppDimensions.SPACING_MD }) {
      // 左侧：标签
      Text(this.label)
        .fontSize(AppDimensions.FONT_SIZE_SM)
        .fontColor(AppColors.TEXT_TERTIARY)
        .width(80)

      // 中间：滑块
      Slider({
        value: this.value,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor(AppColors.SLIDER_THUMB)
        .trackColor(AppColors.SLIDER_TRACK)
        .selectedColor(AppColors.SLIDER_PROGRESS)
        .trackThickness(AppDimensions.SLIDER_HEIGHT)
        .blockSize({ width: AppDimensions.SLIDER_THUMB_SIZE, height: AppDimensions.SLIDER_THUMB_SIZE })
        .layoutWeight(1)
        //双回调
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode === SliderChangeMode.End) {
            if (this.onChangeEnd) {
              this.onChangeEnd(value);
            }
          } else {
            if (this.onValueChange) {
              this.onValueChange(value);
            }
          }
        })

      // 右侧：数值显示
      Text(`${Math.round(this.value)}%`)
        .fontSize(AppDimensions.FONT_SIZE_MD)
        .fontColor(AppColors.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .width(50)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}