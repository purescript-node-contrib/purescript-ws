"use strict";

const WebSocket = require('ws');

exports.createServerImpl = opts => () => {
    return new WebSocket.Server(opts);
}

exports.onConnectionImpl = server => handler => () => {
    server.on('connection', function(ws, req){
        handler(ws)(req)();
    });
}

exports.onError = server => handler => () => {
    server.on('error', function(e){
        handler(e)();
    });
}

exports.onHeaders = server => handler => () => {
    server.on('headers', function(headers, req){
        handler(headers)(req)();
    });
}

exports.listening = server => done => () => {
    server.on('listening', function(){
        done();
    });
}

exports.close = server => done => () => {
    server.close(done);
}


exports.getClientsImpl = server => () => {
    server.clients;
}

exports.handleUpgradeImpl = server => request => socket => buffer => done => () => {
    server.handleUpgrade(request, socket, buffer, done);
}

exports.shouldHandle = server => request => () => {
    server.shouldHandle(request);
}