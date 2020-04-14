module WebSocket (module WS) where 

import WebSocket.Internal ( WebSocket, WebSocketOptions, ReadyState(..), createWebsocket, createWebsocket'
                               , followRedirects, readyState, handshakeTimeout, maxRedirects, protocolVersion, origin, maxPayload
                               , onmessage, onerror, onopen, onping, onpong, onclose, ping, pong, terminate, url, protocol, sendText, send, send', close, close') as WS 