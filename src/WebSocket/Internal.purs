module WebSocket.Internal where 

import Prelude

import Control.Monad.Except (runExcept, throwError, withExcept)
import Data.ByteString (ByteString)
import Data.Either (either)
import Data.Foldable (foldMap)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Effect.Exception (Error, error)
import Foreign (Foreign, renderForeignError)
import Foreign.Generic (class Decode, defaultOptions, genericDecode)
import Foreign.Generic.EnumEncoding (defaultGenericEnumOptions, genericDecodeEnum)
import Prim.Row (class Union)

foreign import data WebSocket :: Type

data WebSocketOptions 

data ReadyState 
    = Connecting 
    | Open 
    | Closing 
    | Closed 

type StatusCode = Int
type SendOptions =
    ( compress :: Boolean 
    , binary   :: Boolean 
    , mask     :: Boolean 
    , fin       :: Boolean 
    )

derive instance genericReadyState :: Generic ReadyState _
derive instance eqReadyState :: Eq ReadyState
instance decodeReadyState :: Decode ReadyState where
  decode = genericDecodeEnum defaultGenericEnumOptions
  
instance showReadyState :: Show ReadyState where 
    show = genericShow

createWebsocket :: String -> Array String -> Options WebSocketOptions -> Effect WebSocket
createWebsocket = createWebsocket' 

createWebsocket':: 
    String 
    -> Array String 
    -> Options WebSocketOptions 
    -> Effect WebSocket 
createWebsocket' addr proto opts = createWebsocketImpl addr proto (options opts)

readyState :: WebSocket -> Effect ReadyState 
readyState ws = do 
    rs <- readyStateImpl ws
    either (throwError <<< error) pure 
        $ runExcept 
        $ withExcept (foldMap renderForeignError) 
        $ genericDecode defaultOptions rs
                
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

sendText :: WebSocket -> String -> Effect Unit
sendText = sendImpl 

send :: WebSocket -> ByteString -> Effect Unit 
send ws bs = sendImpl_ ws bs {binary: true} (pure unit)

send' :: forall opts t. Union opts t SendOptions => WebSocket -> ByteString -> { | opts} -> Effect Unit -> Effect Unit
send' = sendImpl_

onerror :: WebSocket -> (Error -> Effect Unit) -> Effect Unit
onerror = onerrorImpl

onmessage :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit
onmessage = onmessageImpl

onopen :: WebSocket -> Effect Unit -> Effect Unit
onopen = onopenImpl 

onclose :: WebSocket -> Effect Unit -> Effect Unit
onclose = oncloseImpl 

onping :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit 
onping = onpingImpl  

onpong :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit 
onpong = onpongImpl  

ping :: WebSocket -> Effect Unit -> Effect Unit 
ping ws = ping' ws mempty (not $ isServer ws)  

ping' :: WebSocket -> ByteString -> Boolean -> Effect Unit -> Effect Unit 
ping' = pingImpl 

pong :: WebSocket -> Effect Unit -> Effect Unit 
pong ws = pong' ws mempty (not $ isServer ws)  

pong' :: WebSocket -> ByteString -> Boolean -> Effect Unit -> Effect Unit  
pong' = pongImpl 

close :: WebSocket -> Effect Unit 
close = closeImpl_

close' :: WebSocket -> StatusCode -> String -> Effect Unit 
close' = closeImpl 

terminate :: WebSocket -> Effect Unit 
terminate ws = terminateImpl ws

url :: WebSocket -> Maybe String 
url ws = toMaybe $ urlImpl ws

protocol :: WebSocket-> Maybe String 
protocol ws = toMaybe $ protocolImpl ws

foreign import isServer :: WebSocket -> Boolean 
foreign import extensions :: WebSocket -> Foreign
foreign import urlImpl :: WebSocket -> Nullable String 
foreign import protocolImpl :: WebSocket -> Nullable String 
foreign import createWebsocketImpl :: String -> Array String -> Foreign -> Effect WebSocket
foreign import readyStateImpl :: WebSocket -> Effect Foreign 
foreign import sendImpl :: WebSocket -> String -> Effect Unit 
foreign import sendImpl_ :: forall opts. WebSocket -> ByteString -> opts -> Effect Unit -> Effect Unit
foreign import onpingImpl :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit  
foreign import onpongImpl :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit  
foreign import pingImpl :: WebSocket -> ByteString -> Boolean -> Effect Unit -> Effect Unit  
foreign import pongImpl :: WebSocket -> ByteString -> Boolean -> Effect Unit -> Effect Unit  
foreign import onopenImpl :: WebSocket -> Effect Unit -> Effect Unit
foreign import oncloseImpl :: WebSocket -> Effect Unit -> Effect Unit
foreign import onerrorImpl :: WebSocket -> (Error -> Effect Unit) -> Effect Unit
foreign import onmessageImpl :: WebSocket -> (ByteString -> Effect Unit) -> Effect Unit
foreign import closeImpl :: WebSocket -> Int -> String -> Effect Unit
foreign import closeImpl_ :: WebSocket -> Effect Unit
foreign import terminateImpl :: WebSocket -> Effect Unit