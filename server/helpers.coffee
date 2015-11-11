# Misc helper functions which might be used over the site

_ = require 'lodash'
debug = require('debug')('api')
errorTracker = require './config/errors.tracking'

# Validate for email
exports.isValidEmail = (email) ->
  re = RegExp([
    "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:"
    "[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
  ].join(''))
  re.test email



# Method might produce wrong results for 12-symbol words
exports.isObjectId = (_id) -> mongoose.Types.ObjectId.isValid _id

# IMPORTANT: same in mock helpers
exports.HOTSPOTS =
  FILE: 1
  URL: 2
  SLIDE: 3
  EXTERNAL_SLIDE: 4

exports.validationError = (res, err) ->
  if process.env.NODE_ENV? and 'development' is process.env.NODE_ENV
    console.log err
  return res.status(422).json err

exports.handleError = (res, err) ->
  if process.env.NODE_ENV? and 'development' is process.env.NODE_ENV
    console.log err
  env = process.env.NODE_ENV
  if env is 'production' or env is 'staging'
    errorTracker.captureError err
  return res.status 500
    .json
      status: 'error'
      message: err.message


exports.SLIDE_TYPES = [
  'default'
  'calculator'
  'product_presentation'
]

# Slide properties allowed to be changed thru /set call
exports.SLIDE_ALLOWED_PROPERTIES = [
  'title'
  'hidden'
  'internal'
  'links'
  'bgColor'
  'bgImageURL'
  'bgImageId'
  'files'
]

# Chapter properties allowed to be changed thru /set call
exports.CHAPTER_ALLOWED_PROPERTIES = [
  'title'
]

# Presentation properties allowed to be changed thru /set call
exports.PRESENTATION_ALLOWED_PROPERTIES = [
  'title'
  'links'
  'notes'
  'iPadDesktopIcon'
  'editors'
  'approvers'
  'publishedTo'
  'locale'
  'releaseNotes'
]
exports.generateFlexiTemplatSlide = ->
  _content = [
    index: 1
    type: 'calculator'
    subtype: 'flexiTemplate'
    value: []
    bgColor: 'rgba(255, 255, 255, 0)'
    files: []
  ]
  slide =
    order: 0
    template: null
    type: 'calculator'
    title: ''
    size:
      height: 93.75
      width: 100
    customContent:
      calculator:
        value: []
        index: 1
        subtype: 'flexiTemplate'
        files: []
        type: 'calculator'
    content: _content
    contentAreas: [
      offsetY: '0'
      height: '100%'
      width: '100%'
      index: 1
      activeZone:
        height: '100%'
        width: '100%'
        offsetY: '0%'
        offsetX: '0%'
      offsetX: '0'
      cols: 64
      rows: 45
    ]
  return slide

exports.generatePresentation = (template) ->
  throw new Error 'Missing template' unless template?
  throw new Error 'Template is not an object' unless _.isObject template
  # TODO: validate for proper template - all needed fields should be checked
  throw new Error 'Template invalid' unless template._id?
  _content = [
    index: 1
    type: 'text'
    value: ''
    bgColor: 'rgba(255, 255, 255, 0)'
    files: []
  ]
  presentation =
    title: ''
    chapters: [
      title: ''
      order: 0
      slides: [
        order: 0
        type: 'calculator'
        title: ''
        size:
          height: 93.75
          width: 100
        customContent:
          calculator:
            value: []
            index: 1
            subtype: 'flexiTemplate'
            files: []
            type: 'calculator'
        content: _content
        contentAreas: [
          offsetY: '0'
          height: '100%'
          width: '100%'
          index: 1
          activeZone:
            height: '100%'
            width: '100%'
            offsetY: '0%'
            offsetX: '0%'
          offsetX: '0'
          cols: 64
          rows: 45
        ]
        template: template._id
      ]
    ]
  return presentation

exports.generateChapter = (template) ->
  throw new Error 'Missing template' unless template?
  throw new Error 'Template is not an object' unless _.isObject template
  # TODO: validate for proper template - all needed fields should be checked
  throw new Error 'Template invalid' unless template._id?
  _content = []
  for area, iter in template.contentAreas
    _content.push
      index: area.index
      type: 'text'
      value: ''
      custom: {}
  chapter =
    title: ''
    order: 0
    slides: [
      order: 0
      type: 'default'
      title: ''
      content: _content
      template: template._id
      size:
        width: template.size.width
        height: template.size.height
    ]
  return chapter
