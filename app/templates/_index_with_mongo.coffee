"use strict"

http          = require 'http'
express       = require 'express'
<% if(needs_socketio) { %>socketio      = require 'socket.io'<% } %>
bodyParser    = require 'body-parser'
config        = require './config/config'
{MongoClient} = require 'mongodb'

class <%= server_name %>
  constructor: ->
    @app = express()
    @server = http.createServer @app
    <% if(needs_socketio) { %>@io  = socketio @server<% } %>
    @app.use express.static __dirname
    @app.use bodyParser()
    @configure()

  init: (callback) ->
    MongoClient.connect "mongodb://localhost:27017/<%= server_name %>", (error, db) =>
      if error then return callback error
      @db = db
      @collection = db.collection 'docs'
      callback null

  configure: ->
    @app.get '/', (req, res) -> res.sendfile 'index.html'
    
  start: (callback) ->
    port = +process.argv[2] || config.port || 9090
    @server.listen port, () -> callback port

if require.main is module
  server_instance = new <%= server_name %>()
  server_instance.init (error) ->
    if error then return console.log error
    server_instance.start (port) -> console.log "listening on port #{port}."