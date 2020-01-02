"use strict";

const WebSocket = require('ws');

exports.createWebsocketImpl = (addr) => (proto) => (opts) => () => {
    return new WebSocket(addr, proto, opts);
}

exports.onOpenImpl = ws => done => () => {
    ws.onopen = done;
}

exports.onCloseImpl = ws => done => () => {
    ws.onclose = done;
}

exports.onMessageImpl = ws => handler => () => { 
    ws.onmessage = (m) => handler(m.data)();
}

exports.sendImpl = ws => msg => () => {
    ws.send(msg);
}

exports.closeImpl = (ws) => () => { 
    ws.close();
}