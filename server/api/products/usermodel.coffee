mongoose = require 'mongoose'
passwordHash = require 'password-hash'

userSchema = mongoose.Schema
  login:
    type: String
    unique: true
  email:
    type: String
    unique: true
  password: String

userSchema.methods.validPassword = (password) ->
  return passwordHash.verify password, this.password

module.exports = mongoose.model 'User', userSchema
