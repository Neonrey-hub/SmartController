/**
 * 应用颜色常量定义
 * 统一管理应用中的所有颜色，便于主题切换和维护
 */
export class AppColors {
  // 主背景色
  static readonly PRIMARY_BG: string = '#0A1428';
  static readonly SECONDARY_BG: string = '#0B1220';
  static readonly CARD_BG: string = '#121E3A';
  static readonly HEADER_BG: string = '#081F37';
  static readonly CONTENT_BG: string = '#0F1626';

  // 文字颜色
  static readonly TEXT_PRIMARY: string = '#FFFFFF';
  static readonly TEXT_SECONDARY: string = '#E0E6F0';
  static readonly TEXT_TERTIARY: string = '#B0C4D8';
  static readonly TEXT_DISABLED: string = '#5D6D7E';
  static readonly TEXT_PLACEHOLDER: string = '#8899AA';

  // 状态颜色
  static readonly SUCCESS: string = '#2ECC71';      // 绿色 - 在线/成功
  static readonly WARNING: string = '#F39C12';      // 橙色 - 警告
  static readonly ERROR: string = '#E74C3C';        // 红色 - 告警/错误
  static readonly INFO: string = '#3498DB';         // 蓝色 - 信息

  // 控件颜色
  static readonly BUTTON_NORMAL: string = '#1A2A42';
  static readonly BUTTON_HOVER: string = '#253755';
  static readonly BUTTON_BORDER: string = '#2D3E50';
  static readonly BUTTON_TEXT: string = '#C0D0E0';

  // 滑块颜色
  static readonly SLIDER_TRACK: string = '#334155';
  static readonly SLIDER_PROGRESS: string = '#3498DB';
  static readonly SLIDER_THUMB: string = '#FFFFFF';

  // 分隔线颜色
  static readonly DIVIDER: string = '#2D3E50';
  static readonly DIVIDER_DASHED: string = '#8B5CF6';

  // 圆环图颜色
  static readonly RING_BG: string = '#5D6D7E';
  static readonly RING_ACTIVE: string = '#3498DB';

  // 阴影颜色
  static readonly SHADOW_COLOR: string = 'rgba(0, 0, 0, 0.3)';
}