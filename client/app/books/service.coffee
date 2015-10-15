angular.module('przApp').factory 'Books', ($resource) ->
  return $resource '/api/books/:id', id: '@_id'
