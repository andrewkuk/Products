userModel = require '../api/users/usermodel'
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
      if not user
        return done null, false
      if not user.validPassword password
        return done null, false
      return done null, user
    .catch (err) ->
      return done err, false