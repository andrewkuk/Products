express = require 'express'
multer = require 'multer'
upload = multer dest: __dirname + '/uploads/'
controller = require './controller'
adminPanel = require './adminpanel'
router = express.Router()

router.get '/', controller.index
router.post '/', controller.sell
router.get '/admin', adminPanel.index
router.post '/admin', upload.single('file'), adminPanel.addGood
router.post '/admin/vasya', adminPanel.loged

module.exports = router