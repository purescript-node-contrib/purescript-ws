module Node.WebSocket.Server where 

import Prelude

import Data.Options (Option, Options, opt, options, (:=))
import Effect (Effect)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP as HTTP
import Node.Net.Socket as Net
import Node.WebSocket.Internal (WebSocket)

foreign import data WSServer :: Type  

data WSServerOptions 

foreign import data HttpServer :: Type 

data WSServerConfig  =  Port Int | Server HttpServer | NoServer 

createServer :: WSServerConfig -> Options WSServerOptions -> Effect Unit -> Effect WSServer
createServer NoServer opts cb = createServerImpl cb $ options opts 
createServer (Server s) opts cb = 
    createServerImpl cb $ options (opts <> server := s)
createServer (Port p) opts cb = 
    createServerImpl cb $ options (opts <> port := p)

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
clients = getClientsImpl

handleUpgrade :: forall recv send. WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WebSocket recv send -> Effect Unit) -> Effect Unit 
handleUpgrade = handleUpgradeImpl

shouldHandle :: WSServer -> HTTP.Request -> Effect Boolean
shouldHandle = shouldHandleImpl

close :: WSServer -> Effect Unit -> Effect Unit
close wsserver done = closeImpl wsserver done

foreign import createServerImpl :: Effect Unit -> Foreign -> Effect WSServer

foreign import closeImpl  :: WSServer -> Effect Unit -> Effect Unit

foreign import getClientsImpl :: forall recv send. WSServer -> Effect (Array (WebSocket recv send))

foreign import handleUpgradeImpl :: forall recv send. WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WebSocket recv send -> Effect Unit) -> Effect Unit

foreign import shouldHandleImpl :: WSServer -> HTTP.Request -> Effect Boolean