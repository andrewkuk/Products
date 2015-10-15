# Set default node environment to development

process.env.NODE_ENV = process.env.NODE_ENV or 'development'

express = require 'express'
config = require './config/environment'

env = process.env.NODE_ENV
if env is 'production' or env is 'staging'
  errorTracker = require './config/errors.tracking'
  errorTracker.patchGlobal()


# Setup server
# Expose app
exports = module.exports = app = express()
# app = express()
server = require 'http'
  .createServer app
require('./config/express')(app)
require('./routes')(app)

# Start server
server.listen config.port, config.ip, ->
  unless 'test' is app.get 'env'
    console.log 'Express server listening on %d, in %s mode',
      config.port
      app.get('env')
