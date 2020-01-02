"use strict";

const WebSocket = require('ws');

exports.createServerImpl = (opts) => (cb) => () => {
    new WebSocket.Server(opts, cb);
}

exports.closeImpl = (server) => (done) => () => {
    server.close(done);
}

exports.getClientsImpl = (server) => () => {
    server.clients;
}

exports.handleUpgradeImpl = (server) => (request) => (socket) => (buffer) => (done) => () => {
    server.handleUpgrade(request, socket, buffer, done);
}

exports.shouldHandleImpl = (server) => (request) => () => {
    server.shouldHandle(request);
}