// entry/src/main/ets/managers/XfyunAuth.ets
import { CryptoJS } from '@ohos/crypto-js';
import util from '@ohos.util';
import { Constants } from '../common/Constants';

export class XfyunAuth {
  static generateAuthUrl(): string {
    const host = Constants.XFYUN_ASR_HOST;
    const date = new Date().toUTCString();
    const signatureOrigin = `host: ${host}\ndate: ${date}\nGET /v2/iat HTTP/1.1`;

    const signatureSha = CryptoJS.HmacSHA256(signatureOrigin, Constants.XFYUN_API_SECRET);
    const signature = CryptoJS.enc.Base64.stringify(signatureSha);

    const authRaw = `api_key="${Constants.XFYUN_API_KEY}", algorithm="hmac-sha256", headers="host date request-line", signature="${signature}"`;

    const base64 = new util.Base64Helper();
    const authRawUint8 = XfyunAuth.stringToUint8Array(authRaw);
    const authorization = base64.encodeToStringSync(authRawUint8);

    const url = `${Constants.XFYUN_ASR_URL}?authorization=${authorization}&date=${encodeURIComponent(date)}&host=${host}`;
    console.info(`[XfyunAuth] Final URL: ${url}`);
    return url;
  }

  private static stringToUint8Array(str: string): Uint8Array {
    const buf = new ArrayBuffer(str.length);
    const view = new Uint8Array(buf);
    for (let i = 0; i < str.length; i++) {
      view[i] = str.charCodeAt(i);
    }
    return view;
  }
}