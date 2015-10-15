describe 'Books index page', ->
  Books = require './books.po'
  books = new Books
  beforeAll ->
    browser.driver.manage().window().setSize 1024, 768
    browser.get '/books'
    browser.waitForAngular()

  it 'should displayed library title', ->
    expect books.pageTitle.isDisplayed()
      .toBe true
  it 'should display proper text as library title', ->
    expect books.pageTitle.getText()
      .toEqual 'Library'
  it 'should display list', ->
    expect books.list.isDisplayed()
      .toBe true
