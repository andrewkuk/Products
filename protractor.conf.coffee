# An example configuration file.

try
  localConfig = require './local.conf'
catch error
  localConfig = off

SpecReporter = require 'jasmine-spec-reporter'

PORT = process.env.PORT or 3000

exports.config =
  allScriptsTimeout: 15000
  directConnect: yes
  framework: 'jasmine2'
  # Do not start a Selenium Standalone sever - only run this using chrome.
  # chromeDriver: "./node_modules/protractor/selenium/chromedriver"

  # Capabilities to be passed to the webdriver instance.
  capabilities:
    browserName: "chrome"


  # Spec patterns are relative to the current working directly when
  # protractor is called.
  specs: ["e2e/**/*.spec.coffee"]

  # chromeOnly: yes
  seleniumServerJar: './node_modules/protractor/selenium/selenium-server-standalone-2.45.0.jar'
  chromeDriver: "./node_modules/protractor/selenium/chromedriver"

  # seleniumAddress: "http://0.0.0.0:4444/wd/hub"
  baseUrl: 'http://127.0.0.1:3000'
#  baseUrl: localConfig.URLforProtractor or "https://prezentor:g1u3Miij0rBec@p2.prezentor.dk"



  onPrepare: ->

    # jasmineReporters = require "jasmine-spec-reporters"
    jasmine.getEnv().addReporter new SpecReporter()
    # options =
    #   savePath: "./test_reports/e2e/"
    #   consolidate: true
    #   useDotNotation: true
    # jasmine.getEnv().addReporter(new jasmineReporters.JUnitXmlReporter(options.savePath, yes, yes, ''))

  # Options to be passed to Jasmine-node.
  jasmineNodeOpts:
    showColors: true
    defaultTimeoutInterval: 30000
    # isVerbose: true
    silent: true
    print: ->
    realtimeFailure: true
    includeStackTrace: true
