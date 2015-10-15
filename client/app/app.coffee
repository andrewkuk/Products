angular.module 'przApp', [
  # Angular modules
  'ngResource'
  'ui.router'
]

.config (
  $urlRouterProvider
  $locationProvider
  $httpProvider
) ->

#  TODO: need to revert later
#  $urlRouterProvider.otherwise '/my-board'
  $urlRouterProvider.otherwise '/books'

  $locationProvider.html5Mode on
  $httpProvider.interceptors.push 'templatesInterceptor'

.factory 'templatesInterceptor', ($templateCache) ->
  mediaVersion = new Date().getTime()
  request: (request) ->
    if request.method is 'GET' and
    $templateCache.get(request.url) is undefined and
    request.url.match(/(app|components)\/.*.html.*/)
      request.url = request.url + '?v=' + mediaVersion
    return request

.run (
  $rootScope
  $window
  $location
  $state
) ->


  $rootScope.$on "$stateChangeSuccess", ->

  $rootScope.$on '$stateChangeStart', (event, next) ->
