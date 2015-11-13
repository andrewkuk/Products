module.exports.index = (req, res) ->
  res.render 'login'

module.exports.isLoggedIn = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  else
    res.redirect '/products/login'

module.exports.logged = (req,res) ->
  res.render 'adminpanel'