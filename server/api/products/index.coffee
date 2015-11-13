passport = require 'passport'
multer = require 'multer'
upload = multer dest: __dirname + '/uploads/'
controller = require './controller'
adminPanel = require './adminpanel'
login = require './login'
require('../../config/passport')(passport)

module.exports = (router) ->
  router.get '/test', login.isLoggedIn, login.logged
  router.get '/', controller.index
  router.post '/', controller.sell
  router.get '/login', login.index
  router.post '/admin',
    passport.authenticate 'local',
    failureRedirect: '/products/login'
    login.logged
  router.post '/admin/addgood',
    login.isLoggedIn,
    upload.single('file'),
    adminPanel.addGood