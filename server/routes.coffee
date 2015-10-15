# Main application routes
path = require 'path'

errors = require './components/errors'

module.exports = (app) ->
  app.use '/api/books', require './api/books'

  # All undefined asset or api routes should return a 404
  app.route("/:url(api|auth|components|app|bower_components|assets)/*")
    .get errors[404]

  app.route("/*").get (req, res) ->
    res.sendFile path.resolve "#{app.get 'appPath' }/index.html"
