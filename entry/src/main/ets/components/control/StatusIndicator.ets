// entry/src/main/ets/components/control/StatusIndicator.ets
import { AppColors } from '../../constants/AppColors'
import { AppDimensions } from '../../constants/AppDimensions'

@Component
export struct StatusIndicator {
  @Prop name: string = '';
  @Prop isEnabled: boolean = false;
  @Prop color: string = AppColors.TEXT_DISABLED;
  onToggle?: (enabled: boolean) => void;
  private lastToggleTime: number = 0;

  build() {
    Row({ space: AppDimensions.SPACING_SM }) {
      Circle()
        .width(12).height(12)
        .fill(this.isEnabled ? this.color : AppColors.TEXT_DISABLED)
        .opacity(this.isEnabled ? 1 : 0.3)
        .shadow({ radius: this.isEnabled ? 6 : 0, color: this.isEnabled ? this.color : 'transparent' })
      Text(this.name)
        .fontSize(AppDimensions.FONT_SIZE_SM)
        .fontColor(this.isEnabled ? AppColors.TEXT_PRIMARY : AppColors.TEXT_TERTIARY)
        .fontWeight(this.isEnabled ? FontWeight.Medium : FontWeight.Normal)
      Blank()
      if (this.isEnabled) {
        Text('已开启')
          .fontSize(10).fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .backgroundColor(`${this.color}30`).borderRadius(6)
      }
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.isEnabled ? `${this.color}10` : '#121E3A')
    .borderRadius(12)
    .borderWidth(1.5)
    .borderColor(this.isEnabled ? `${this.color}40` : '#2D3E50')
    .onClick(() => {
      const now = Date.now();
      if (now - this.lastToggleTime > 300) {
        this.lastToggleTime = now;
        if (this.onToggle) this.onToggle(!this.isEnabled);
      }
    })
  }
}