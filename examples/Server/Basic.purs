module Examples.Server.Basic where

import Prelude

import Data.ByteString as BS
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Node.WebSocket as WS
import Node.WebSocket.Server as WSS

-- import Prelude

-- import Control.Monad.Rec.Class (forever)
-- import Data.Tuple (Tuple(..))
-- import Effect (Effect)
-- import Effect.Aff (Aff, Milliseconds(..), delay, forkAff, launchAff_)
-- import Effect.Class.Console as Console
-- import Node.WebSocket (ReadyState(..))
-- import Node.WebSocket (close, createWebsocket, onMessage, readyState, send) as WS
-- import Node.WebSocket.Server as WSS

main :: Effect Unit
main = do
    websocketServer
    websocketClient

websocketServer :: Effect Unit
websocketServer = do 
    wss <- WSS.createServer' (WSS.Port 8080) mempty do 
                Console.log "listening on port 8080"

    WSS.onconnection wss \ws req -> do 
        Console.log "New Connection!"
        WS.onmessage ws \msg -> do 
            Console.log $ "received: " <> BS.fromUTF8 msg
        
        WS.send ws $ BS.toUTF8 "Thanks!"

websocketClient :: Effect Unit 
websocketClient = do 
    ws <- WS.createWebsocket "ws://localhost:8080/" [] mempty

    WS.onopen ws do 
        Console.log "connected"
        WS.send ws (BS.toUTF8 "Hello, World")

    WS.onmessage ws \bs -> do 
        Console.log (BS.fromUTF8 bs <> ": from echo!")
        launchAff_ do 
            delay $ Milliseconds 1000.00 
            liftEffect do 
                WS.send ws (BS.toUTF8 "Hello, World!") 