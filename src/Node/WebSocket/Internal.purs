module Node.WebSocket.Internal where 

import Data.Generic.Rep (class Generic)
import Prelude

import Control.Monad.Except (runExcept, throwError, withExcept)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Either (either)
import Data.Foldable (foldMap)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Effect.Aff (Aff, error, makeAff, nonCanceler)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign, renderForeignError)
import Foreign.Generic (class Decode, defaultOptions, genericDecode)
import Foreign.Generic.EnumEncoding (defaultGenericEnumOptions, genericDecodeEnum)
import Node.Buffer (Buffer)
import Node.Buffer.Internal as Buffer

foreign import data WebSocket :: Type -> Type -> Type

-- newtype WebSocket recv send  = WebSocket WS 

data WebSocketOptions 

data ReadyState 
    = Connecting 
    | Open 
    | Closing 
    | Closed 

derive instance genericReadyState :: Generic ReadyState _
derive instance eqReadyState :: Eq ReadyState
instance decodeReadyState :: Decode ReadyState where
  decode = genericDecodeEnum defaultGenericEnumOptions
  
instance showReadyState :: Show ReadyState where 
    show = genericShow

class MessageType (a :: Type) 
instance messageTypeString :: MessageType String 
instance messageTypeBuffer :: MessageType Buffer 
instance messageTypeArrayBuffer :: MessageType ArrayBuffer 

-- | This  function attaches the attaches the onError event on creation and will throw the error as an 
-- | asychronous error.
createWebsocket :: String -> Array String -> Options WebSocketOptions -> Aff (WebSocket String String)
createWebsocket = createWebsocket' 

createWebsocket' :: forall recv send. 
    MessageType recv 
    => MessageType send 
    => String 
    -> Array String 
    -> Options WebSocketOptions 
    -> Aff (WebSocket recv send)
createWebsocket' addr proto opts = fromEffectFnAff $ createWebsocketImpl_ addr proto (options opts)

readyState :: forall recv send. (WebSocket recv send) -> Aff ReadyState 
readyState ws = either (throwError <<< error) pure 
                    $ runExcept 
                    $ withExcept (foldMap renderForeignError) 
                    $ genericDecode defaultOptions
                    $ readyStateImpl ws

send :: forall recv send. MessageType send => WebSocket recv send -> send -> Aff Unit
send ws msg = makeAff $ \done -> do 
    res <- sendImpl_ ws msg
    done $ pure res
    pure nonCanceler

onMessage :: forall recv send. MessageType recv => WebSocket recv send -> Aff recv
onMessage ws = fromEffectFnAff $ onMessageImpl ws

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

ping :: forall recv send. WebSocket recv send -> Aff Unit
ping ws = Buffer.create 0 >>= ping' ws

ping' :: forall recv send. WebSocket recv send -> Buffer -> Aff Unit 
ping' ws buff = makeAff \done  -> do 
    res <- pingImpl ws buff
    done $ pure res 
    pure nonCanceler

pong :: forall recv send. WebSocket recv send -> Aff Unit
pong ws = Buffer.create 0 >>= pong' ws

pong' :: forall recv send. WebSocket recv send -> Buffer ->  Aff Unit 
pong' ws buff = makeAff \done  -> do 
    res <- pongImpl ws buff
    done $ pure res 
    pure nonCanceler

onPing :: forall recv send. WebSocket recv send -> Effect Unit -> Aff Unit
onPing ws action = makeAff \done -> do  
    res <- onPingImpl ws action
    done $ pure res 
    pure nonCanceler

onPong :: forall recv send. WebSocket recv send -> Effect Unit -> Aff Unit
onPong ws action = makeAff \done -> do  
    res <- onPongImpl ws action
    done $ pure res 
    pure nonCanceler

maxPayload :: Option WebSocketOptions Int 
maxPayload = opt "maxPayload"

close :: forall recv send. WebSocket recv send -> Aff Unit 
close ws = makeAff \done -> do
    _ <- closeImpl ws
    done $ pure unit 
    pure nonCanceler

terminate :: forall recv send. WebSocket recv send -> Aff Unit 
terminate ws = makeAff \done -> do
    _ <- terminateImpl ws
    done $ pure unit 
    pure nonCanceler

url :: forall recv send. WebSocket recv send -> Maybe String 
url ws = toMaybe $ urlImpl ws

protocol :: forall recv send. WebSocket recv send -> Maybe String 
protocol ws = toMaybe $ protocolImpl ws

foreign import urlImpl :: forall recv send. WebSocket recv send -> Nullable String 

foreign import protocolImpl :: forall recv send. WebSocket recv send -> Nullable String 

foreign import createWebsocketImpl_ :: forall recv send. String -> Array String -> Foreign -> EffectFnAff (WebSocket recv send)

foreign import readyStateImpl :: forall recv send. WebSocket recv send -> Foreign 

foreign import sendImpl_ :: forall recv send. WebSocket recv send -> send -> Effect Unit 

foreign import pingImpl :: forall recv send a. WebSocket recv send -> Buffer -> Effect a

foreign import pongImpl :: forall recv send a. WebSocket recv send -> Buffer -> Effect a

foreign import onPingImpl :: forall recv send a. WebSocket recv send -> Effect Unit -> Effect a

foreign import onPongImpl :: forall recv send a. WebSocket recv send -> Effect Unit -> Effect a

foreign import onMessageImpl :: forall recv send. WebSocket recv send -> EffectFnAff recv 

foreign import closeImpl :: forall recv send. WebSocket recv send -> Effect Unit

foreign import terminateImpl :: forall recv send. WebSocket recv send -> Effect Unit