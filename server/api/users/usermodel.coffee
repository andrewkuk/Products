mongoose = require 'mongoose'
passwordHash = require 'password-hash'
permisions = require './permisions'

userSchema = mongoose.Schema
  login:
    type: String
    unique: true
  email:
    type: String
    unique: true
  password: String
  role: String
  permisions:
    purchase: Boolean
    changeAmount: Boolean
    createUser: Boolean
      
userSchema.statics.hashPassword = (password) ->
  return passwordHash.generate password, saltLength: 10, iterations: 3

userSchema.methods.validPassword = (password) ->
  return passwordHash.verify password, this.password

userSchema.methods.setPermisions = () ->
  this.permisions.purchase = permisions.permissions[this.role].purchase
  this.permisions.changeAmount = permisions.permissions[this.role].changeAmount
  this.permisions.createUser = permisions.permissions[this.role].createUser

module.exports = mongoose.model 'User', userSchema

# add cart like widget or like another link to page with cart
# pdf with amount name images and total price to pay