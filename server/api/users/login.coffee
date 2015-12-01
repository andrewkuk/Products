#admin = new userModel
  #login: 'Adam'
  #email: 'adam@gmail.com'
  #password: userModel.hashPassword 'passwordA'
  #role: 'admin'
#manager = new userModel
  #login: 'Max'
  #email: 'max@gmail.com'
  #password: userModel.hashPassword 'passwordM'
  #role: 'manager'
#user = new userModel
  #login: 'Ujin'
  #email: 'ujin@gmail.com'
  #password: userModel.hashPassword 'passwordU'
  #role: 'user'
#admin.setPermisions()
#manager.setPermisions()
#user.setPermisions()
  
module.exports.index = (req, res) ->
  #console.log req.session
  #console.log req
  #userModel.find {}
  #.then (users) ->
    #for user in users
      #user.remove()
      #user.setPermisions()
      #console.log user
  res.render 'login'

module.exports.logged = (req, res) ->
  if req.user.permisions.createUser
    res.redirect '/admin'
  else
    res.redirect '/products'
  