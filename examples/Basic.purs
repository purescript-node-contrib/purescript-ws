module Examples.Basic where 

import Prelude

import Data.Options ((:=))
import Effect (Effect)
import Effect.Class.Console (log) as Console
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.WebSocket (WebSocket, createWebsocket, createWebsocket', origin, onOpen, onClose, onMessage, close, send) as WS

main :: Effect Unit
main = do
    Console.log "Executing websocket..."
    websocket

-- Example demonstrating how to receive string message and send string message
websocket :: Effect Unit 
websocket = do
  ws <- WS.createWebsocket "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
  WS.onOpen ws do 
    Console.log "Connected"
    WS.send ws "Hello, world"

  WS.onClose ws $ do
    Console.log "Connection Closed" 
    Console.log mempty

    Console.log "Executing websocketBuffer..."
    websocketBuffer

  WS.onMessage ws \message -> do
    Console.log $ "Echo From Client(String): " <> message
    WS.close ws 

-- Example demonstrating how to receive buffer message and send string message
-- WS.createWebsocket' function will require you to specify your receive and send MessageType - instance for (String, Buffer, andArrayBuffer) are predefined
websocketBuffer :: Effect Unit 
websocketBuffer = do
  (ws :: WS.WebSocket Buffer String) <- WS.createWebsocket' "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
  WS.onOpen ws do 
    Console.log "Connected"
    WS.send ws "Hello, world"

  WS.onClose ws $ 
    Console.log "Connection Closed" 

  WS.onMessage ws \message -> do
    msg <- Buffer.toString UTF8 message
    Console.log $ "Echo From Client(Buffer): " <> msg
    WS.close ws 