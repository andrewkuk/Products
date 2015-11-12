mongoose = require 'mongoose'

userSchema = mongoose.Schema
  login:
    type: String
    unique: true
  email:
    type: String
    unique: true
  password: String

module.exports = mongoose.model 'User', userSchema
