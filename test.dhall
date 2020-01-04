let conf = ./spago.dhall

in conf // {
  sources = [ "test/**/*.purs" ],
  dependencies = conf.dependencies # [ "console" ]
}