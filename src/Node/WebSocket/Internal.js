"use strict";

const WebSocket = require('ws');

exports.createWebSocketImpl = (addr) => (proto) => (opts) => () => {
    return (proto === null ? new WebSocket(addr, opts) : new WebSocket(addr, proto, opts));
}