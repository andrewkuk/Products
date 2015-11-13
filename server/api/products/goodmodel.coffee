mongoose = require 'mongoose'

goodsSchema = mongoose.Schema
  #_id: Number
  price: Number
  description: String
  amount: Number
  image:
    thumb: String
    full: String
  
goodsSchema.methods.sell = (purchaseAmount) ->
  if this.amount - purchaseAmount < 0
    Promise.reject new Error "big amount"
  else
    this.update amount: this.amount - purchaseAmount

module.exports = mongoose.model 'Goods', goodsSchema