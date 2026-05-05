import { network_connect } from "ets/network/network_connect";
let TryConnectConut = 0
export function isnetwork_connect(){

  if (!network_connect.state && TryConnectConut < 3 ) {
    console.log("isconnect")
    network_connect.reconnect()
    TryConnectConut ++
  }else if (TryConnectConut > (1*60) || network_connect.state) {
    TryConnectConut = 0
    console.log("connect_status",network_connect.state,TryConnectConut)
  }else {
    TryConnectConut ++
    console.log("connect_status",network_connect.state,TryConnectConut)
  }
}