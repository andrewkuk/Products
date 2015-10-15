angular.module 'przApp'
.controller 'BooksCtrl', ($scope, Books) ->
  $scope.books = Books.query()
