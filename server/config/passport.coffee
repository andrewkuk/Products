userModel = require '../api/products/usermodel'
LocalStrategy = require('passport-local').Strategy

module.exports = (passport) ->
  passport.serializeUser (user, done) ->
    done null, user.login
  passport.deserializeUser (login, done) ->
    userModel.findOne login: login, (err, user) ->
      done err, user
  passport.use 'local', new LocalStrategy
    usernameField: 'login'
    passwordField: 'password'
  , (login, password, done) ->
    userModel.findOne $or: [login: login,
      email: login]
    .then (user) ->
      if !user
        return done null, false
      if !user.validPassword password
        return done null, false
      return done null, user
    .catch (err) ->
      return done err, false