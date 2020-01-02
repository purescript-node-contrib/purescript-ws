module Node.WebSocket 
    ( module WS
    ) where 

import Node.WebSocket.Internal ( WebSocket, WebSocketOptions, ReadyState, class MessageType, createWebsocket'
                               , followRedirects, handshakeTimeout, maxRedirects, protocolVersion, origin, maxPayload
                               , onOpen, onClose, onMessage, send, close) as WS 

