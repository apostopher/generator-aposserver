"use strict"

http       = require 'http'
express    = require 'express'
_          = require 'lodash'
<% if(needs_socketio) { %>socketio   = require 'socket.io'<% } %>
bodyParser = require 'body-parser'
config     = require './config/config'
domainMiddleware = require 'domain-middleware'

class <%= server_name %>
  constructor: ->
    @app = express()
    @server = http.createServer @app
    <% if(needs_socketio) { %>@io  = socketio @server<% } %>
    @app.use domainMiddleware server: @server
    @app.use express.static __dirname
    @app.use bodyParser.urlencoded extended: false
    @app.use bodyParser.json()
    @configure()
    @app.use (error, req, res, next) -> res.send "unexpected error occured."

  configure: ->
    @app.get '/', (req, res) -> res.sendFile 'index.html', root: __dirname
    
  start: (callback) ->
    port = +process.argv[2] || config.port || 9090
    @server.listen port, () -> callback port

  shutdown: (error, req, res) ->
    console.error 'error', error.stack
    try
      dietimer = setTimeout ->
        console.log 'bye bye world :-('
        process.exit 1
      , 30000
      dietimer.unref()
      @server.close()

      res.statusCode = 500
      res.setHeader 'content-type', 'text/plain'
      res.end 'Oops, there was a problem!\n'
    catch error2
      console.error 'Error sending 500!', error2.stack
  


if require.main is module
  server_instance = new <%= server_name %>()
  server_instance.start (port) -> console.log "listening on port #{port}."