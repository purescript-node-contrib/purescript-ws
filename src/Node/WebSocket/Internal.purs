module Node.WebSocket.Internal where 

import Prelude

import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Foreign (Foreign)
import Node.Buffer (Buffer)

foreign import data WS :: Type

newtype WebSocket recv send  = WebSocket WS 

data WebSocketOptions 

data ReadyState 
    = Connecting 
    | Open 
    | Closing 
    | Closed 

class MessageType (a :: Type) 

instance messageTypeString :: MessageType String 
instance messageTypeBuffer :: MessageType Buffer 
instance messageTypeArrayBuffer :: MessageType ArrayBuffer 

-- createWebsocket :: String -> Maybe String -> Options WebSocketOptions -> Effect (WebSocket String String)
-- createWebsocket addr proto opts = createWebSocketImpl addr (toNullable proto) opts

createWebsocket' :: forall recv send. 
    MessageType recv 
    => MessageType send 
    => String 
    -> Maybe String 
    -> Options WebSocketOptions 
    -> Effect (WebSocket recv send)
createWebsocket' addr proto opts = WebSocket <$> createWebSocketImpl addr (toNullable proto) (options opts) 

followRedirects :: Option WebSocketOptions Boolean 
followRedirects = opt "followRedirects"

handshakeTimeout :: Option WebSocketOptions Int 
handshakeTimeout =  opt "handshakeTimeout"

maxRedirects :: Option WebSocketOptions Int 
maxRedirects = opt  "maxRedirects"

protocolVersion :: Option WebSocketOptions Int 
protocolVersion = opt "protocolVersion"

origin :: Option WebSocketOptions String 
origin = opt "origin"

maxPayload :: Option WebSocketOptions Int 
maxPayload = opt "maxPayload"

onOpen :: forall recv send. WebSocket recv send -> Effect Unit -> Effect Unit 
onOpen (WebSocket ws) done = onOpenImpl ws done

onClose :: forall recv send. WebSocket recv send -> Effect Unit -> Effect Unit 
onClose (WebSocket ws) done = onCloseImpl ws done
 
onMessage :: forall recv send. MessageType recv => WebSocket recv send -> (recv -> Effect Unit) -> Effect Unit 
onMessage (WebSocket ws) = onMessageImpl ws

close :: forall recv send. WebSocket recv send -> Effect Unit 
close (WebSocket ws) = closeImpl ws

send :: forall recv send. MessageType send => WebSocket recv send -> send -> Effect Unit
send (WebSocket ws) = sendImpl ws 

foreign import closeImpl :: WS -> Effect Unit 

foreign import onOpenImpl ::  WS -> Effect Unit -> Effect Unit

foreign import onMessageImpl :: forall recv. WS -> (recv -> Effect Unit) -> Effect Unit 

foreign import onCloseImpl :: WS-> Effect Unit -> Effect Unit

foreign import sendImpl :: forall send. WS -> send -> Effect Unit 

foreign import createWebSocketImpl :: String -> Nullable String -> Foreign -> Effect WS