import {Socket} from "phoenix"

let chatInput = $("#chat-input")
let messagesContainer = $("#messages")
var data = []

let socket = new Socket("/ws")
socket.connect()
let chan = socket.chan("rooms:lobby", {})

chatInput.on("keypress", event => {
  if(event.keyCode === 13) {
    chan.push("new_msg", {body: chatInput.val()})
    chatInput.val("")
  }
})

chan.on("new_msg", payload => {
  messagesContainer.append(`<br>[${Date()}] ${payload.body}`)
  if(typeof data[payload.id] === 'undefined')
    data[payload.id] = payload
  console.log(data)
})

chan.join().receive("ok", chan => {
  console.log("Success!")
})

let App = {

}

export default App
