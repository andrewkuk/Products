faker = require 'faker'
exports.index = (req, res) ->
  books = []
  for i in [1..10]
    books.push
      _id: i
      author: faker.name.findName()
      title: faker.company.catchPhrase()

  res.json books
