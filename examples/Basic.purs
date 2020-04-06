module Examples.Basic where 

import Prelude

import Data.ByteString as BS
import Data.Options ((:=))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log) as Console
import Node.WebSocket (ReadyState(..))
import Node.WebSocket (close, createWebsocket, onclose, onmessage, onopen, onping, origin, ping, readyState, send, terminate) as WS

main :: Effect Unit
main = websocket

websocket :: Effect Unit 
websocket = do 
    ws <- WS.createWebsocket "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
    let hearbeat = do 
            delay $ Milliseconds 2000.00
            liftEffect $ WS.terminate ws  

    WS.onopen ws (launchAff_ hearbeat)
        
    WS.onping ws (const $ launchAff_ hearbeat)

    WS.onclose ws do 
        Console.log "disconnected"

websocket2 :: Effect Unit 
websocket2 = do 
    ws <- WS.createWebsocket "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
    
    WS.onopen ws do 
        Console.log "connected"
        WS.send ws (BS.toUTF8 "Hello, World")
        
    WS.onmessage ws \bs -> do 
        Console.log (BS.fromUTF8 bs <> ": from echo!")
        launchAff_ do 
            delay $ Milliseconds 100.00 
            liftEffect do 
                WS.send ws (BS.toUTF8 "Hello, World!")
                WS.close ws 

    WS.onclose ws do 
        Console.log "disconnected"
