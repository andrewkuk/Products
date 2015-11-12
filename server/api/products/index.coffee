express = require 'express'
multer = require 'multer'
upload = multer dest: __dirname + '/uploads/'
controller = require './controller'
adminPanel = require './adminpanel'
login = require './login'
router = express.Router()

router.get '/', controller.index
router.post '/', controller.sell
router.get '/admin', login.index
router.post '/admin', upload.single('file'), adminPanel.addGood
router.post '/admin/vasya', login.logged

module.exports = router