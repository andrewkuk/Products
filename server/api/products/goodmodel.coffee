mongoose = require 'mongoose'

goodsSchema = mongoose.Schema
  #_id: Number
  #purchaseAmount: Number
  price: Number
  description: String
  amount: Number
  image:
    thumb: String
    full: String
  
goodsSchema.methods.sell = (purchaseAmount) ->
  #if this.amount - purchaseAmount < 0
    #Promise.reject new Error "big amount"
  #else
  this.amount -= purchaseAmount
  this.save()

goodsSchema.methods.changeAmount = (newAmount) ->
  this.amount = newAmount
  this.save()

module.exports = mongoose.model 'Goods', goodsSchema