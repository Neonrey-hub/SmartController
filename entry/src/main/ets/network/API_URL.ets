import { network_connect, WebSocket_connect } from "ets/network/network_connect";
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

// export let API_URL = "119.29.15.120"
//
// export function ChangeApiIP(IP:string){
//   API_URL = IP
//   setTimeout(()=>{
//     network_connect.reconnect()
//   },1500)
// }
// F:\ArkTS\Project\SmartController\entry\src\main\ets\network\API_URL.ets



const PREF_NAME: string = 'api_config';
const KEY_API_URL: string = 'api_url';
const DEFAULT_API_URL: string = '119.29.15.120';

// ⬇️ 变量名保持不变
export let API_URL: string = DEFAULT_API_URL;

// Preferences 实例（模块级单例）
let dataPreferences: preferences.Preferences | null = null;

/**
 * 初始化：读取本地存储的 API URL 到 API_URL 变量
 * 应在 EntryAbility.onCreate 中调用一次
 */
export async function initApiUrl(context: Context): Promise<void> {
  try {
    // 获取 Preferences 实例（文件不存在会自动创建）
    dataPreferences = preferences.getPreferencesSync(context, { name: PREF_NAME });

    // 读取已存储的 API URL，没有则使用默认值
    API_URL = dataPreferences.getSync(KEY_API_URL, DEFAULT_API_URL) as string;
    console.info(`[API_URL] 初始化完成，当前 API_URL: ${API_URL}`);
  } catch (err) {
    const error = err as BusinessError;
    console.error(`[API_URL] 初始化失败, code: ${error.code}, message: ${error.message}`);
    API_URL = DEFAULT_API_URL;
  }
}

/**
 * 修改 API URL，同时写入本地文件持久化
 * 外部调用此方法即可完成修改 + 持久化
 */
export async function ChangeApiIP(newUrl: string): Promise<void> {
  if (!dataPreferences) {
    console.error('[API_URL] Preferences 未初始化，请先调用 initApiUrl()');
    return;
  }

  try {
    // 写入内存缓存
    dataPreferences.putSync(KEY_API_URL, newUrl);
    // 异步持久化到文件
    dataPreferences.flush((err: BusinessError) => {
      if (err) {
        console.error(`[API_URL] 持久化失败, code: ${err.code}, message: ${err.message}`);
        return;
      }
      API_URL = newUrl;
      console.info(`[API_URL] 修改成功，新 API_URL: ${API_URL}`);
        setTimeout(()=>{
          network_connect.reconnect()
        },1500)
    });
  } catch (err) {
    const error = err as BusinessError;
    console.error(`[API_URL] 修改失败, code: ${error.code}, message: ${error.message}`);
  }
}