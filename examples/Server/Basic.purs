module Examples.Server.Basic where

import Prelude

import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, forkAff, launchAff_)
import Effect.Class.Console as Console
import Node.WebSocket (ReadyState(..))
import Node.WebSocket (close, createWebsocket, onMessage, readyState, send) as WS
import Node.WebSocket.Server as WSS

main :: Effect Unit
main = launchAff_ $ websocketServer

-- Our server
websocketServer :: Aff Unit 
websocketServer = do 
    server <- WSS.createServer (WSS.Port 8080) mempty 
    Console.log "listening on port 8080"

    -- Forking two clients 
    _ <- forkAff $ websocketClient "1"   
    _ <- forkAff $ websocketClient "2"

    -- Connection handler, if we do not loop it will only handle one request.
    void $ forever do 
        (Tuple ws _) <- WSS.onConnection server
        Console.log "Client connected"

        forkAff $ do
            msg <- WS.onMessage ws
            Console.log $ "Server received: " <> msg
            WS.send ws "Hello back"
  
-- Our client websocket 
websocketClient :: String -> Aff Unit 
websocketClient s = do 
    w <- WS.createWebsocket "ws://localhost:8080/" [] mempty
    loop w
    where 
        loop ws = do 
            delay $ Milliseconds 500.00  --  Need some sort of delay or we will be stuck  on the connection state
            ready <- WS.readyState ws
            case ready of  
                Connecting -> (Console.log $ "client " <> s <> " connected") *> loop ws
                Closed -> Console.log $ "client " <> s <> " closed"
                Open -> do
                    Console.log $  "client " <> s <> " open"
                    WS.send ws "Hello, World!"
                    

                    void $ forkAff $ do
                        msg <- WS.onMessage ws
                        Console.log $ "Client received: " <> msg
                        WS.close ws
                        Console.log $ "Closing client " <> s                 
                _ -> pure unit 