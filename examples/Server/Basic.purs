module Examples.Server.Basic where

import Prelude

import Effect (Effect)
import Effect.Class.Console as Console
import Node.WebSocket (WebSocket, createWebsocket, onMessage, onOpen, send) as WS
import Node.WebSocket.Server as WSS

main :: Effect Unit
main = websocketServer

websocketServer :: Effect Unit 
websocketServer = do 
    server <- WSS.createServer (WSS.Port 8080) mempty 

    WSS.onConnection server $ \(ws :: WS.WebSocket String String) _ -> do 
        WS.onMessage ws $ \msg -> do 
            Console.log $ "received: " <> msg
            Console.log $ "Shutting down server..."
            WSS.close server $ pure unit 

    WSS.listening server $ do 
        Console.log "Listening on port 8080"
        Console.log mempty
        -- Executing the websocket client once server is listening
        websocketClient

websocketClient :: Effect Unit 
websocketClient = do 
    ws <- WS.createWebsocket "ws://localhost:8080/" [] mempty

    WS.onOpen ws do 
        WS.send ws "Hello from client!"