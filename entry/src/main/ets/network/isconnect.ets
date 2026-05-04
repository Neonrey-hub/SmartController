import { network_connect } from "ets/network/network_connect";

export function isnetwork_connect(){
  if (!network_connect.state) {
    console.log("isconnect")
    network_connect.reconnect()
  }
}