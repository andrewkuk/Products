fsp = require 'fs-promise'
gm = require 'gm'
.subClass imageMagick: true
path = require 'path'
GoodsModel = require './goodmodel'

module.exports.addGood = (req, res) ->
  fileUrlThumb = "/assets/images/thumb/" + req.file.originalname
  fileUrlFull = "/assets/images/" + req.file.originalname
  fileStorePath = path.normalize(__dirname + "/../../.." + "/build")
  filePath = fileStorePath + fileUrlFull
  fsp.rename req.file.path, filePath
  .then (complite) ->
    Good = new GoodsModel
      price: req.body.price
      description: req.body.description
      amount: req.body.amount
      image:
        thumb: fileUrlThumb
        full: fileUrlFull
    
    gm filePath
    .fill 'white'
    .fontSize 32
    .drawText 0,0, "@VasyaPupkin", 'SouthEast'
    .write filePath, (err) ->
      if err
        console.log err
      else
        gm filePath
        .thumbnail 128, 128
        .write fileStorePath + fileUrlThumb, (err) ->
          if err
            console.log err
          else
          Good.save()
          res.redirect '/products'
  .catch (err) ->
    console.log err