"use strict"

_          = require 'lodash'
{ObjectID} = require 'mongodb'


class RESTController
  constructor: (db, @resource_name, @result_key = 'result') ->
    @collection = db.collection resource_name
    @options = {}

  set: (option, value) -> @options[option] = value

  setupRoutes: (app) ->
    app.get "/#{@resource_name}/:owner/get", (_.bind @get, @), (_.bind @endRequest, @)
    app.get "/#{@resource_name}/:owner/get/:id", (_.bind @getOne, @), (_.bind @endRequest, @)
    app.post "/#{@resource_name}/:owner/add", (_.bind @add, @), (_.bind @endRequest, @)
    app.put "/#{@resource_name}/:owner/update/:id", (_.bind @update, @), (_.bind @endRequest, @)
    app.delete "/#{@resource_name}/:owner/remove/:id", (_.bind @remove, @), (_.bind @endRequest, @)

  endRequest: (req, res, next) ->
    if @options["end request"] is true
      res.set 'Content-Type', 'application/json'
      return res.send 200, res[@result_key]
    return next()

  get: (req, res, next) ->
    owner = req.params.owner
    @collection.find({owner}).toArray (error, docs) =>
      if error then return next error
      res[@result_key] = docs
      next()

  getOne: (req, res, next) ->
    owner = req.params.owner
    _id   = new ObjectID req.params.id
    @collection.findOne {_id, owner}, (error, doc) =>
      if error then return next error
      res[@result_key] = doc
      next()

  add: (req, res, next) ->
    data = req.body || {}
    owner = req.params.owner
    data.owner = owner

    if @options["add create time"] is true
      data["created_at"] = Date.now

    @collection.insert data, (error, docs) =>
      if error then return next error
      res[@result_key] = docs
      next()

  update: (req, res, next) ->
    data = req.body || {}
    _id    = new ObjectID req.params.id
    owner = req.params.owner

    if @options["add update time"] is true
      data["updated_at"] = Date.now

    @collection.update {_id, owner}, {$set: _.omit data, '_id'}, (error, num_of_updated_docs) =>
      if error then return next error
      res[@result_key] = updated: num_of_updated_docs
      next()

  remove: (req, res, next) ->
    owner = req.params.owner
    _id    = new ObjectID req.params.id
    @collection.remove {_id, owner}, (error, num_of_removed_docs) =>
      if error then return next error
      res[@result_key] = removed: num_of_removed_docs
      next()

module.exports = RESTController