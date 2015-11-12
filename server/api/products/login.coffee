passwordHash = require 'password-hash'
UserModel = require './usermodel'

module.exports.index = (req, res) ->
  res.render 'login'

module.exports.logged = (req,res) ->
  UserModel.findOne $or: [login: req.body.login,
    email: req.body.login]
  .then (user) ->
    if passwordHash.verify req.body.password, user.password
      res.render 'adminpanel'
    else
      res.send "Error"
  .catch (err) ->
    res.send "Error" 
