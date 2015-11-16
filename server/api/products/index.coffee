controller = require './controller'
permissions = require '../users/permisions'

module.exports = (router) ->
  router.get '/', controller.index
  router.post '/purchase', permissions.checkPurchase, controller.sell
  router.post '/changeamount',
    permissions.checkChangeAmount,
    controller.changeAmount