module Node.WebSocket.Server where 

import Prelude

import Data.ByteString (ByteString)
import Data.Options (Option, Options, opt, options, (:=))
import Effect (Effect)
import Effect.Aff (Error)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP as HTTP
import Node.Net.Socket as Net
import Node.WebSocket.Internal (WebSocket)

foreign import data WSServer :: Type  

data WSServerOptions 

data WSServerConfig  =  Port Int | Server HTTP.Server | NoServer 

createServer :: WSServerConfig -> Options WSServerOptions -> Effect Unit -> Effect WSServer
createServer NoServer opts action   = createServerImpl (options (opts <> noServer := true)) action
createServer (Server s) opts action = createServerImpl (options (opts <> server := s)) action 
createServer (Port p) opts action   = createServerImpl (options (opts <> port := p)) action

port :: Option WSServerOptions Int 
port = opt "port" 

server :: Option WSServerOptions HTTP.Server
server = opt "server"

noServer :: Option WSServerOptions Boolean
noServer = opt "noServer"

host :: Option WSServerOptions String 
host = opt "host"

backlog :: Option WSServerOptions Int 
backlog = opt "backlog"

path :: Option WSServerOptions Int 
path = opt "path"

maxPayload :: Option WSServerOptions Int
maxPayload = opt "maxPayload"

handleUpgrade :: WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WebSocket -> Effect Unit) -> Effect Unit 
handleUpgrade = handleUpgradeImpl 

onconnection :: WSServer -> (WebSocket -> HTTP.Request -> Effect Unit) -> Effect Unit
onconnection = onconnectionImpl 

onerror :: WSServer -> (Error -> Effect Unit) -> Effect Unit
onerror = onerrorImpl

onclose :: WSServer -> Effect Unit -> Effect Unit
onclose = oncloseImpl

onlistening :: WSServer -> Effect Unit -> Effect Unit 
onlistening = onlisteningImpl

onheaders :: WSServer -> (Array ByteString -> HTTP.Request -> Effect Unit) -> Effect Unit 
onheaders = onheadersImpl 

shouldHandle :: WSServer -> HTTP.Request -> Boolean 
shouldHandle = shouldHandleImpl 

close :: WSServer -> Effect Unit 
close svr = close' svr (pure unit) 

close' :: WSServer -> Effect Unit -> Effect Unit 
close' = closeImpl 

foreign import createServerImpl  :: Foreign -> Effect Unit -> Effect WSServer
foreign import closeImpl         :: WSServer -> Effect Unit -> Effect Unit
foreign import handleUpgradeImpl :: WSServer -> HTTP.Request -> Net.Socket -> Buffer -> (WebSocket -> Effect Unit) -> Effect Unit 
foreign import shouldHandleImpl  :: WSServer -> HTTP.Request -> Boolean
foreign import onconnectionImpl  :: WSServer -> (WebSocket -> HTTP.Request -> Effect Unit) -> Effect Unit 
foreign import onerrorImpl       :: WSServer -> (Error -> Effect Unit) -> Effect Unit 
foreign import oncloseImpl       :: WSServer -> Effect Unit -> Effect Unit 
foreign import onlisteningImpl   :: WSServer -> Effect Unit -> Effect Unit 
foreign import onheadersImpl     :: WSServer -> (Array ByteString -> HTTP.Request -> Effect Unit) -> Effect Unit 