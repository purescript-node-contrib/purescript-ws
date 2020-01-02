module Examples.Basic where 

import Prelude

import Data.Maybe (Maybe(..))
import Data.Options ((:=))
import Effect (Effect)
import Effect.Class.Console (log) as Console
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.WebSocket (WebSocket, createWebsocket', origin, onOpen, onClose, onMessage, close, send) as WS

main :: Effect Unit
main = do
  (ws :: WS.WebSocket Buffer String) <- WS.createWebsocket' "wss://echo.websocket.org/" Nothing $ WS.origin := "https://websocket.org"
  WS.onOpen ws do 
    Console.log "Connected"
    WS.send ws "Hello, world"

  WS.onClose ws $ 
    Console.log "Connection Closed" 

  WS.onMessage ws \message -> do
    msg <- Buffer.toString UTF8 message
    Console.log $ "Echo From Client: " <> msg
    WS.close ws 