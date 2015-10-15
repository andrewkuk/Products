angular.module 'przApp'
.config ($stateProvider) ->
  $stateProvider
  .state 'books',
    url: '/books'
    templateUrl: 'app/books/books.html'
    controller: 'BooksCtrl'
