// entry/src/main/ets/common/Constants.ets
import common from '@ohos.app.ability.common';

export class Constants {
  static readonly SAMPLE_RATE: number = 16000;
  static readonly CHANNEL_COUNT: number = 1;
  static readonly BUFFER_SIZE: number = 1280;

  static readonly XFYUN_APP_ID: string = "8d199df8";
  static readonly XFYUN_API_KEY: string = "dafaf8072a1e3534f96ebdcbf1f5c3e4";
  static readonly XFYUN_API_SECRET: string = "Njc4NDQ3NzJkN2I1NTRkMDkwMjJmZjA2";
  static readonly XFYUN_ASR_HOST: string = "iat-api.xfyun.cn";
  static readonly XFYUN_ASR_URL: string = "wss://iat-api.xfyun.cn/v2/iat";
}

/**
 * 退出确认管理器：用于在子页面触发返回时，处理"再按一次退出"逻辑并杀掉进程
 */
export class ExitConfirmManager {
  /** 是否显示退出提示 */
  static showExitHint: boolean = false
  /** 退出提示计时器 */
  private static exitHintTimer: number = -1

  /**
   * 处理返回键：在子页面的 onBackPressed 中调用
   * @returns true 表示拦截返回，false 表示允许退出并杀掉进程
   */
  static handleBackPress(): boolean {
    if (ExitConfirmManager.showExitHint) {
      // 第二次按下，杀掉进程
      console.info('第二次返回，杀掉进程')
      if (ExitConfirmManager.exitHintTimer !== -1) {
        clearTimeout(ExitConfirmManager.exitHintTimer)
        ExitConfirmManager.exitHintTimer = -1
      }
      ExitConfirmManager.showExitHint = false
      
      // 杀掉应用进程
      ExitConfirmManager.terminateApp()
      
      return false  // 允许退出
    } else {
      // 第一次按下，显示提示并拦截
      ExitConfirmManager.showExitHint = true
      
      // 2秒后自动重置
      ExitConfirmManager.exitHintTimer = setTimeout(() => {
        ExitConfirmManager.showExitHint = false
        ExitConfirmManager.exitHintTimer = -1
      }, 2000)
      
      return true  // 拦截返回
    }
  }

  /**
   * 杀掉应用进程
   */
  private static terminateApp(): void {
    try {
      // 获取 UIAbility 上下文
      const context = getContext() as common.UIAbilityContext
      // 终止应用进程
      context.terminateSelf()
      console.info('应用进程已终止')
    } catch (error) {
      console.error('终止应用进程失败:', JSON.stringify(error))
    }
  }

  /**
   * 重置状态：在 Index 页面切换 Tab 时调用
   */
  static reset(): void {
    ExitConfirmManager.showExitHint = false
    if (ExitConfirmManager.exitHintTimer !== -1) {
      clearTimeout(ExitConfirmManager.exitHintTimer)
      ExitConfirmManager.exitHintTimer = -1
    }
  }
}