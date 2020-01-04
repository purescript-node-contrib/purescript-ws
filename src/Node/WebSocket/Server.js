"use strict";

const WebSocket = require('ws');

exports.createServerImpl = opts => (onError, onSuccess) => {
    let server = new WebSocket.Server(opts);

    server.on('error', onError)
    server.on('listening', () => onSuccess(server))

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}

exports.onConnectionImpl = server => tuple => (onError, onSuccess) => {
    server.on('connection', function(ws, req){
        onSuccess(tuple(ws)(req))
    })
    
    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}

exports.closeImpl = server => (onError, onSuccess) => {
    server.close(onSuccess);

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}


exports.handleUpgradeImpl = server => request => socket => buffer => done => (onError, onSuccess) => {
    server.handleUpgrade(request, socket, buffer, onSuccess);

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}

exports.shouldHandleImpl = server => request => (onError, onSuccess) => {
    onSuccess(server.shouldHandle(request))

    return (cancelError, onCancelerError, onCancelerSuccess) => {
        onCancelerSuccess()
    }
}