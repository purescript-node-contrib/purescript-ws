"use strict";

const WebSocket = require('ws');

exports.createWebsocketImpl = addr => proto => opts => () => {
    return new WebSocket(addr, proto, opts)
}

exports.readyStateImpl = websocket => () => {
    let readyState = (state) => ({
        0: "Connecting",
        1: "Open",
        2: "Closing",
        3: "Closed"
    })[state]

    return { tag: readyState(websocket.readyState) }
}

exports.sendImpl = ws => data => options => action => () => {
    ws.send(data, options, action)
}

exports.pingImpl = ws => data => mask => action => () => {
    ws.ping(data, mask, action)
}

exports.pongImpl = ws => data => mask => action => () => {
    ws.pong(data, mask, action)
}

exports.closeImpl = (ws) => code => reason => () => { 
    ws.close(code, reason)
}

exports.closeImpl_ = (ws) => () => ws.close()

exports.onopenImpl = ws => cb => () => {
    ws.onopen = cb
}

exports.oncloseImpl = ws => cb => () => {
    ws.onclose = cb
}

exports.onmessageImpl = ws => cb => () => { 
    ws.onmessage = (e) => {
        cb(e.data)()
    }
}

exports.onpingImpl = ws => cb => () => {
    ws.on('ping', (data) => cb(data)())
}

exports.onpongImpl = ws => cb => () => {
    ws.on('pong', (data) => cb(data)())
}

exports.onerrorImpl = ws => cb => () => {
    ws.on('error', (err) => { 
        cb(err)()
    })
}

exports.terminateImpl = ws => () => ws.terminate()

exports.protocolImpl = ws => ws.protocol

exports.urlImpl = ws => ws.url

exports.extensions = ws => ws.extensions

exports.isServer = ws => ws._isServer 