# Express configuration
path = require 'path'
bodyParser = require 'body-parser'
passport = require 'passport'
errorHandler = require 'errorhandler'
methodOverride = require 'method-override'
cookieParser = require 'cookie-parser'
session = require 'express-session'
config = require './environment'

module.exports = (app, express) ->
  #app.use express.static('../build/assets')
  env = app.get 'env'
  app.disable 'x-powered-by'
  app.set 'views', config.root + '/server/views'
  app.set 'view engine', 'jade'
  app.use bodyParser.urlencoded extended: no
  app.use bodyParser.json limit: '20mb'
  app.use methodOverride()
  app.use cookieParser()
  app.use session {secret: 'gooooog'}
  app.use passport.initialize()
  app.use passport.session()
  require('./passport')(passport)
  # app.use compression()
  if 'production' is env or 'staging' is env
    app.use express.static path.join config.root, 'public'
    app.set 'appPath', config.root + '/prezentor/public'
  if 'development' is env or 'test' is env
    app.set 'appPath', config.root + '/build'
    app.use express.static path.join config.root, 'build'
    #console.log config.root
    app.use errorHandler()
