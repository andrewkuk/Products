class Books
  constructor: ->
    @pageTitle = element By.css 'h1.title'
    @list = element By.css 'table.library'

module.exports = Books
