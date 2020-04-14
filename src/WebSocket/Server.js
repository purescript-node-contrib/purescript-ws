"use strict";

const WebSocket = require('ws');

exports.createServerImpl = opts => (cb) => () => {
    return new WebSocket.Server(opts, cb)
}

exports.onerrorImpl = server => cb => () => {
    server.on('error', (err) => {
        cb(err)()
    })
}

exports.oncloseImpl = server => cb => () => {
    server.on('close', cb)
}

exports.onlisteningImpl = server => cb => () => {
    server.on('listening', cb)
}

exports.onheadersImpl = server => cb => () => {
    server.on('headers', (headers, req) => {
        cb(headers)(req)
    })
}

exports.onconnectionImpl = server => cb => () => {
    server.on('connection', (ws, req) =>{
        cb(ws)(req)()
    })
}
exports.onupgradeImpl = server => cb => () => {
    server.on('upgrade', (request, socket, buffer) => {
        cb(request)(socket)(buffer)()
    })
}

exports.closeImpl = server => cb => () => {
    server.close(cb);
}

exports.handleUpgradeImpl = server => request => socket => buffer => cb => () =>{
    server.handleUpgrade(request, socket, buffer, (ws) => {
        cb(ws)()
    })
}

exports.shouldHandleImpl = server => request => {
    server.shouldHandle(request)
}