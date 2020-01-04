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
            


    


-- -- Example demonstrating how to receive string message and send string message
-- websocket :: Effect Unit 
-- websocket = do
--   ws <- WS.createWebsocket "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
--   WS.onOpen ws do 
--     Console.log "Connected"
--     WS.send ws "Hello, world"

--   WS.onClose ws $ do
--     Console.log "Connection Closed" 
--     Console.log mempty

--     Console.log "Executing websocketBuffer..."
--     websocketBuffer

--   WS.onMessage ws \message -> do
--     Console.log $ "Echo From Client(String): " <> message
--     WS.close ws 

-- -- Example demonstrating how to receive buffer message and send string message
-- -- WS.createWebsocket' function will require you to specify your receive and send MessageType - instance for (String, Buffer, andArrayBuffer) are predefined
-- websocketBuffer :: Effect Unit 
-- websocketBuffer = do
--   (ws :: WS.WebSocket Buffer String) <- WS.createWebsocket' "wss://echo.websocket.org/" [] $ WS.origin := "https://websocket.org"
--   WS.onOpen ws do 
--     Console.log "Connected"
--     WS.send ws "Hello, world"

--   WS.onClose ws $ 
--     Console.log "Connection Closed" 

--   WS.onMessage ws \message -> do
--     msg <- Buffer.toString UTF8 message
--     Console.log $ "Echo From Client(Buffer): " <> msg
--     WS.close ws 