module Node.WebSocket.Server where 

import Prelude

import Data.Options (Option, Options, opt, options, (:=))
import Effect (Effect)
import Effect.Exception (Error)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP as HTTP
import Node.Net.Socket as Net
import Node.WebSocket.Internal (WS, WebSocket(..))

foreign import data WSServer :: Type  

data WSServerOptions 

foreign import data HttpServer :: Type 

data WSServerConfig  =  Port Int | Server HttpServer | NoServer 

createServer :: WSServerConfig -> Options WSServerOptions -> Effect WSServer
createServer NoServer opts = createServerImpl $ options opts 
createServer (Server s) opts = 
    createServerImpl $ options (opts <> server := s)
createServer (Port p) opts = 
    createServerImpl $ options (opts <> port := p)

port :: Option WSServerOptions Int 
port = opt "port" 

server :: Option WSServerOptions HttpServer
server = opt "server"

host :: Option WSServerOptions String 
host = opt "host"

backlog :: Option WSServerOptions Int 
backlog = opt "backlog"

path :: Option WSServerOptions Int 
path = opt "path"

clientTracking :: Option WSServerOptions Boolean
clientTracking = opt "clientTracking"

maxPayload :: Option WSServerOptions Int
maxPayload = opt "maxPayload"

clients :: forall recv send. WSServer -> Effect (Array (WebSocket recv send))
clients svr = do 
    clts <- getClientsImpl svr 
    pure $ WebSocket <$> clts

handleUpgrade :: forall recv send. WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WebSocket recv send -> Effect Unit) -> Effect Unit 
handleUpgrade svr req sock buff cb = handleUpgradeImpl svr req sock buff $ \ws -> cb (WebSocket ws)

onConnection :: forall recv send. WSServer -> (WebSocket recv send -> HTTP.Request -> Effect Unit) -> Effect Unit 
onConnection svr cb = onConnectionImpl svr $ \ws req -> cb (WebSocket ws) req

foreign import createServerImpl :: Foreign -> Effect WSServer

foreign import close  :: WSServer -> Effect Unit -> Effect Unit

foreign import getClientsImpl :: WSServer -> Effect (Array WS)

foreign import handleUpgradeImpl :: WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WS -> Effect Unit) -> Effect Unit

foreign import shouldHandle :: WSServer -> HTTP.Request -> Effect Boolean

foreign import onConnectionImpl :: WSServer -> (WS -> HTTP.Request ->  Effect Unit) -> Effect Unit 

foreign import onError :: WSServer -> (Error -> Effect Unit)  -> Effect Unit 

foreign import onHeaders :: WSServer -> (Array String -> HTTP.Request -> Effect Unit)  -> Effect Unit 

foreign import listening :: WSServer -> Effect Unit -> Effect Unit