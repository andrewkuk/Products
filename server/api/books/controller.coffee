faker = require 'faker'

books = []
for i in [1..10]
  books.push
    _id: i
    author: faker.name.findName()
    title: faker.company.catchPhrase()


exports.index = (req, res) -> res.json books
