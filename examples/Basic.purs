module Examples.Basic where 

import Prelude

import Data.Options ((:=))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Class.Console (log) as Console
import Node.WebSocket (ReadyState(..))
import Node.WebSocket (createWebsocket, readyState, origin, onMessage, send) as WS

main :: Effect Unit
main = launchAff_ websocket


websocket :: Aff Unit 
websocket = do 
    ws <- WS.createWebsocket "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
    loop ws
    where 
        loop ws = do 
            ready <- WS.readyState ws
            delay $ Milliseconds 500.00 --  Need some sort of delay or we will be stuck  on the connection state
            case ready of  
                Closed -> pure unit 
                Open -> do
                    Console.log "open"
                    WS.send ws "Hello, World!"
                    msg <- WS.onMessage ws  
                    Console.log $ "Received: " <> msg 
                    loop ws
                _ -> Console.log "connected" *> loop ws