{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "bytestrings"
  , "effect"
  , "foreign-generic"
  , "node-buffer"
  , "node-http"
  , "node-net"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
