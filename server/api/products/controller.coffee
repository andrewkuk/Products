faker = require 'faker'
bodyParser = require 'body-parser'
Promise = require 'bluebird'
fs = require 'fs'
GoodsModel = require './goodmodel'

#products = []
#for i in [1..10]
  #products.push new GoodsModel
    #_id: i
    #price: faker.finance.amount()
    #description: faker.company.catchPhrase()
    #amount: faker.random.number(300)
#for product in products
  #products[i-1].save()
  #.then null, (err) ->
    #console.log err
  #.catch (err) ->
    #console.log err

bindIdWithNewAmount = (id, amount) ->
  GoodsModel.findById id
  .then (good) ->
    good.changeAmount amount

bindIdWithAmount = (id, amount) ->
  GoodsModel.findById id
  .then (good) ->
    good.sell amount

module.exports.index = (req, res) ->
  #console.log permision
  GoodsModel.find {}
  .then (goods) ->
    #for good in goods
      #good.remove()
    res.render 'index', goods: goods, user: req.user
  .catch (err) ->
    console.log err
    res.send err.message

module.exports.sell = (req, res) ->
  promiseArray = []
  for id, amount of req.body
    promiseArray.push bindIdWithAmount "#{id}", "#{amount}"
  Promise.all promiseArray
  .then (goods) ->
    res.redirect '/products'
  .catch (err) ->
    console.log err
    res.send String fs.readFileSync __dirname + '/erroramount.html'
    
module.exports.changeAmount = (req, res) ->
  promiseArray = []
  for id, amount of req.body
    promiseArray.push bindIdWithNewAmount "#{id}", "#{amount}"
  Promise.all promiseArray
  .then (goods) ->
    res.redirect '/products'
  .catch (err) ->
    console.log err
    res.send "Error"