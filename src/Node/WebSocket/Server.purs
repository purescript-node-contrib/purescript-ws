module Node.WebSocket.Server where 

import Prelude

import Data.Options (Option, Options, opt, options, (:=))
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP as HTTP
import Node.Net.Socket as Net
import Node.WebSocket.Internal (WebSocket)

foreign import data WSServer :: Type  

data WSServerOptions 

foreign import data HttpServer :: Type 

data WSServerConfig  =  Port Int | Server HttpServer | NoServer 

createServer :: WSServerConfig -> Options WSServerOptions -> Aff WSServer
createServer NoServer opts = fromEffectFnAff $ createServerImpl $ options opts
createServer (Server s) opts = fromEffectFnAff $ createServerImpl $ options (opts <> server := s)
createServer (Port p) opts = fromEffectFnAff $ createServerImpl $ options (opts <> port := p)

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

handleUpgrade :: forall recv send. WSServer -> HTTP.Request -> Net.Socket -> Buffer -> Aff (WebSocket recv send) 
handleUpgrade svr req sock buff = fromEffectFnAff $ handleUpgradeImpl svr req sock  buff

onConnection :: forall recv send. WSServer -> Aff (Tuple (WebSocket recv send) HTTP.Request) 
onConnection svr = fromEffectFnAff $ onConnectionImpl svr Tuple

shouldHandle :: WSServer -> HTTP.Request -> Aff Boolean 
shouldHandle svr req = fromEffectFnAff $ shouldHandleImpl svr req 

close :: WSServer -> Aff Unit 
close svr = fromEffectFnAff $ closeImpl svr

foreign import createServerImpl :: Foreign -> EffectFnAff WSServer

foreign import closeImpl  :: WSServer -> EffectFnAff Unit

foreign import handleUpgradeImpl :: forall recv send. WSServer -> HTTP.Request -> Net.Socket -> Buffer -> EffectFnAff (WebSocket recv send)

foreign import shouldHandleImpl :: WSServer -> HTTP.Request -> EffectFnAff Boolean

foreign import onConnectionImpl :: forall recv send a b. WSServer -> (a -> b -> Tuple a b) -> EffectFnAff (Tuple (WebSocket recv send) HTTP.Request) 

-- TO DO: Do we really need these two functions?
-- foreign import getClientsImpl :: WSServer -> Effect (Array WS)
-- foreign import onHeaders :: WSServer -> (Array String -> HTTP.Request -> Effect Unit)  -> Effect Unit 