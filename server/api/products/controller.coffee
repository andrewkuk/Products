faker = require 'faker'
bodyParser = require 'body-parser'
Promise = require 'bluebird'
fs = require 'fs'
GoodsModel = require './goodmodel'
PDFDoc = require 'pdfkit'

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

bindIdWithQty = (id, quantity, checking) ->
  GoodsModel.findById id
  .then (good) ->
    new Promise (resolve, reject) ->
      if checking
        if (parseInt(good.amount) - parseInt(quantity)) < 0
          console.log "err"
          reject new Error "big amount"
      goodWithQty = {}
      goodWithQty.good = good
      goodWithQty.quantity = parseInt(quantity)
      resolve goodWithQty

module.exports.index = (req, res) ->
  GoodsModel.find {}
  .then (goods) ->
    #for good in goods
      #good.remove()
    res.render 'index', goods: goods, user: req.user, cart: req.session.cart
  .catch (err) ->
    console.log err
    res.send err.message

module.exports.sell = (req, res) ->
  promiseArray = []
  for id, quantity of req.body
    if parseInt("#{quantity}") isnt 0
      promiseArray.push bindIdWithQty "#{id}", "#{quantity}", true
  Promise.all promiseArray
  .then (goodsWithQty) ->
    Promise.map promiseArray, (goodWithQty) ->
      goodWithQty.good.sell goodWithQty.quantity
    .then (goods) ->
      res.redirect '/products'
  .catch (err) ->
    console.log err
    res.send String fs.readFileSync __dirname + '/erroramount.html'
    
module.exports.changeAmount = (req, res) ->
  promiseArray = []
  for id, quantity of req.body
    if parseInt("#{quantity}") > 0
      promiseArray.push bindIdWithQty "#{id}", "#{quantity}", false
  Promise.map promiseArray, (goodWithQty) ->
    goodWithQty.good.changeAmount goodWithQty.quantity
    return goodWithQty.good
  .then (goods) ->
    res.redirect '/products'
  .catch (err) ->
    console.log err
    res.send "Error"

module.exports.addToCart = (req, res) ->
  promiseArray = []
  cart = req.session.cart
  for id, quantity of req.body
    if parseInt("#{quantity}") > 0
      if not cart
        cart = []
      promiseArray.push bindIdWithQty "#{id}", "#{quantity}", true
  Promise.all promiseArray
  .then (goodsWQty) ->
    for goodWQty in goodsWQty
      # check if cart no empty
      if cart.length
        #check if product alredy in cart
        exist = cart.some (product) ->
          productId = product.good._id.toString()
          goodId = goodWQty.good._id.toString()
          return if productId is goodId
            product.quantity += goodWQty.quantity
        # if product not in cart
        if not exist
          cart.push(goodWQty)
      else
        # if cart empty
        cart.push(goodWQty)
    req.session.cart = cart
    res.render "cart", cart: cart
  .catch (err) ->
    console.log err
    res.send "error"
    
module.exports.remove = (req, res) ->
  console.log req.params.id
  console.log req.session.cart
  req.session.cart = req.session.cart.filter (product) ->
    return product.good._id isnt req.params.id
  console.log req.session.cart.length
  if not req.session.cart.length
    delete req.session.cart
    res.send req.session.cart
  else  
    res.render "cartdata", cart: req.session.cart
  #res.redirect '/products'
  
module.exports.check = (req, res) ->
  promiseArray = []
  for product in req.session.cart
    promiseArray.push bindIdWithQty product.good._id, product.quantity, true
  Promise.all promiseArray
  .then (goodsWithQty) ->
    Promise.map promiseArray, (goodWithQty) ->
      goodWithQty.good.sell goodWithQty.quantity
    .then (goods) ->
      #create PDF
      filePath = './build/assets/app/checks/'
      fileName = req.sessionID + '.pdf'
      fileUrl = filePath + fileName
      check = new PDFDoc
      stream = check.pipe fs.createWriteStream fileUrl
      lineSpace = 0
      finalPrice = 0
      width = 70
      y = 100
      check.text "Description", 200, 30,
        width: width
        align: 'center'
      check.text "Price", 270, 30,
        width: width
        align: 'center'
      check.text "Quantity", 340, 30,
        width: width
        align: 'center'
      check.text "Total Price", 410, 30,
        align: 'center'
      for product in req.session.cart
        quantityPrice = (product.good.price * product.quantity).toFixed(2)
        finalPrice += parseFloat quantityPrice
        #check.image "build/" + product.good.image.thumb, 50, 50 + lineSpace
        check.text product.good.description, 200, y + lineSpace,
          align: 'center'
          width: width
        check.text product.good.price.toFixed(2), 270, y + lineSpace,
          align: 'center'
          width: width
        check.text product.quantity, 340, y + lineSpace,
          align: 'center'
          width: width
        check.text quantityPrice, 410, y + lineSpace,
          align: 'right'
        lineSpace += 128
        if lineSpace > 550
          check.addPage()
          lineSpace = 0
      check.text "Final Price = " + finalPrice.toFixed(2), 350, 110 + lineSpace,
        align: 'right'
      check.end()
      stream.on 'finish', () ->
        delete req.session.cart
        res.download fileUrl, "check.pdf"
  .catch (err) ->
    console.log err
    res.send String fs.readFileSync __dirname + '/erroramount.html'