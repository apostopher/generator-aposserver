"use strict"

express    = require 'express'
bodyParser = require 'body-parser'
config     = require './config/config'

class <%= server_name %>
  constructor: ->
    @app = express()
    @app.use express.static __dirname
    @app.use bodyParser()
    @configure()

  configure: ->
    @app.get '/', (req, res) -> res.sendfile 'index.html'
    
  start: (callback) ->
    port = +process.argv[2] || config.port || 9090
    @app.listen port, () -> callback port

if require.main is module
  server_instance = new <%= server_name %>()
  server_instance.start (port) -> console.log "listening on port #{port}."