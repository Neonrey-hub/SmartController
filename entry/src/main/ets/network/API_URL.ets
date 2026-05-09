import { network_connect, WebSocket_connect } from "ets/network/network_connect";
export let API_URL = "119.29.15.12"

export function ChangeApiIP(IP:string){
  API_URL = IP
  setTimeout(()=>{
    network_connect.reconnect()
  },1500)
}