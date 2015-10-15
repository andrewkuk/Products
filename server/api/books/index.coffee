express = require 'express'
controller = require './controller'
router = express.Router()

router.get '/', controller.index
# router.get '/:_id', auth.isAuthenticated(), controller.show
# router.post '/', auth.isAuthenticated(), controller.create
# router.put '/:_id', auth.isAuthenticated(), controller.update

module.exports = router
