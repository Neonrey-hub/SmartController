import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';

interface coils{"name":string,"enabled":boolean}
interface brightness{"percent":number}

@ObservedV2
export class API{
  private  url:string = "http://10.241.148.11:8090";
  private httpRequest = http.createHttp();

  check_green(enabled:boolean){
    this.API_coils("green",enabled)
  }
  check_red(enabled:boolean){
    this.API_coils("red",enabled)
  }
  check_yellow(enabled:boolean){
    this.API_coils("yellow",enabled)
  }
  check_buzzer(enabled:boolean){
    this.API_coils("buzzer",enabled)
  }
  API_coils(name:string,enabled:boolean){
    this.API_http(`{"name":"${name}","enabled":${enabled}}`,"/api/control/coil")
    console.log(`{"name":"${name}","enabled":${enabled}`)
  }

  API_brightness(num:number){
    this.API_http(`{"percent":${num}}`,"/api/control/brightness")
  }

  API_fan(num:number){
    this.API_http(`{"percent":${num}}`,"/api/control/fan")
  }
  async API_http(data:string,API:string){
    console.log(this.url+API)
    try {
      let JSON_DATA = JSON.parse(data) as coils | brightness
      const response = await this.httpRequest.request(this.url+API, {
        method: http.RequestMethod.POST,
        connectTimeout: 10000,
        readTimeout: 10000,
        extraData:JSON_DATA
      });

    } catch (err) {
      console.error("请求异常：", (err as BusinessError).message);
    }
  }


}
export const curb_hardware:API = new API()