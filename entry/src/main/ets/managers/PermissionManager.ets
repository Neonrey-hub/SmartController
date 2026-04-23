// entry/src/main/ets/managers/PermissionManager.ets
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';

export class PermissionManager {
  private static atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  static async checkAndRequestPermissions(context: common.UIAbilityContext): Promise<boolean> {
    const permissions: Array<Permissions> = ['ohos.permission.MICROPHONE', 'ohos.permission.INTERNET'];
    try {
      let allGranted = true;
      for (const perm of permissions) {
        const grantStatus = await PermissionManager.atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm);
        if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          allGranted = false;
          break;
        }
      }
      if (allGranted) return true;

      const result = await PermissionManager.atManager.requestPermissionsFromUser(context, permissions);
      return result.authResults.every(r => r === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
    } catch (err) {
      console.error(`[PermissionManager] error: ${JSON.stringify(err)}`);
      return false;
    }
  }
}