controller = require './controller'
permissions = require '../users/permisions'

module.exports = (router) ->
  router.get '/', controller.index
  router.post '/purchase', permissions.checkPurchase, controller.sell
  router.post '/changeamount',
    permissions.checkChangeAmount,
    controller.changeAmount
  router.post '/addToCart', controller.addToCart
  router.get '/add/:id', controller.remove
  router.get '/checkout', permissions.checkPurchase, controller.check
  router.post '/changequa/:id', controller.changeQuantity