userModel = require './usermodel'

module.exports.checkPurchase = (req, res, next) ->
  if req.isAuthenticated() and req.user.permisions.purchase
    return next()
  else
    res.redirect '/user/login'

module.exports.checkChangeAmount = (req, res, next) ->
  if req.isAuthenticated() and req.user.permisions.changeAmount
    return next()
  else
    res.redirect '/user/login'

module.exports.checkCreateUser = (req, res, next) ->
  if req.isAuthenticated() and req.user.permisions.createUser
    return next()
  else
    res.redirect '/user/login'
  
module.exports.isLoggedIn = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  else
    res.redirect '/user/login'

module.exports.permissions =
  user:
    purchase: true
    changeAmount: false
    createUser: false
  manager:
    purchase: true
    changeAmount: true
    createUser: false
  admin:
    purchase: true
    changeAmount: true
    createUser: true