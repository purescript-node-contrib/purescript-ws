"use strict";

const WebSocket = require('ws');

exports.createServerImpl = (opts) => (cb) => () => {
    return new WebSocket.Server(opts, cb);
}

exports.closeImpl = (server) => (done) => () => {
    return server.close(done);
}

exports.getClientsImpl = (server) => () => {
    return server.clients;
}

exports.handleUpgradeImpl = (server) => (request) => (socket) => (buffer) => (done) => () => {
    return server.handleUpgrade(request, socket, buffer, done);
}

exports.shouldHandleImpl = (server) => (request) => () => {
    return server.shouldHandle(request);
}