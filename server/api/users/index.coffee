passport = require 'passport'
permissions = require './permisions'
login = require './login'

module.exports = (router) ->
  router.get '/login', login.index
  router.post '/login',
    passport.authenticate 'local',
    failureRedirect: '/user/login'
    login.logged
