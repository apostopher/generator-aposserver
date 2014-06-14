"use strict"

http       = require 'http'
express    = require 'express'
<% if(needs_socketio) { %>
socketio   = require 'socket.io'
<% } %>
bodyParser = require 'body-parser'
config     = require './config/config'

class <%= server_name %>
  constructor: ->
    @app = express()
    @server = http.createServer @app
    <% if(needs_socketio) { %>
    @io  = socketio @server
    <% } %>
    @app.use express.static __dirname
    @app.use bodyParser()
    @configure()

  configure: ->
    @app.get '/', (req, res) -> res.sendfile 'index.html'
    
  start: (callback) ->
    port = +process.argv[2] || config.port || 9090
    @server.listen port, () -> callback port

if require.main is module
  server_instance = new <%= server_name %>()
  server_instance.start (port) -> console.log "listening on port #{port}."