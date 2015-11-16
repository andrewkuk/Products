multer = require 'multer'
upload = multer dest: __dirname + '/uploads/'
adminPanel = require './adminpanel'
permissions = require '../users/permisions'

module.exports = (router) ->
  router.get '/', permissions.checkCreateUser, adminPanel.index
  router.post '/addgood',
    permissions.checkCreateUser,
    upload.single('file'),
    adminPanel.addGood
  router.get '/createUser', permissions.isLoggedIn, adminPanel.createUser
  router.post '/createUser', permissions.checkCreateUser, adminPanel.addUser
