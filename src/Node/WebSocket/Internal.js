"use strict";

const WebSocket = require('ws');

exports.createWebsocketImpl_ = (addr) => (proto) => (opts) => (onError, onSuccess) => {
    let websocket = new WebSocket(addr, proto, opts)
    websocket.onerror = onError; 
    onSuccess(websocket)

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        websocket.terminate()
        onCancelerSuccess()
    }
}

exports.readyStateImpl = (websocket) => {
    let readyState = (state) => ({
        0: "Connecting",
        1: "Open",
        2: "Closing",
        3: "Closed"
    })[state]

    return { tag: readyState(websocket.readyState) }
}

exports.sendImpl_ = ws => msg => () => {
    ws.send(msg)
}

exports.pingImpl = ws => buff => () => {
    ws.ping(buff);
}

exports.pongImpl = ws => buff => () => {
    ws.pong(buff);
}


exports.onPingImpl = ws => done => () => {
    ws.on('ping', done)
}

exports.onPongImpl = ws => done => () => {
    ws.on('pong', done)
}

exports.closeImpl = (ws) => () => { 
    ws.close();
}

exports.onMessageImpl = ws => (onError, onSuccess) => { 
    ws.onmessage = (e) => onSuccess(e.data);

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}

exports.terminateImpl = ws => () => {
    ws.terminate();
}

exports.protocolImpl = ws => {
    ws.protocol;
}
exports.urlImpl = ws => {
    ws.url;
}