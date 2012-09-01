'use strict';

angular.module('myApp', ['myApp.filters', 'myApp.services', 'myApp.directives']).config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider
    .when('/', {
      templateUrl: '/partials/index',
      controller: 'IndexCtrl'
    })
    .when('/book/:id', {
      templateUrl: '/partials/viewBook',
      controller: 'ViewBookCtrl'
    })
    .when('/readBook/:id', {
      templateUrl: '/partials/readBook',
      controller: 'ReadBookCtrl'
    })
    .when('/readByLines/:id', {
      templateUrl: '/partials/readByLines',
      controller: 'ReadByLinesCtrl'
    })
    .when('/addBook', {
      templateUrl: '/partials/addBook',
      controller: 'AddBookCtrl'
    })
    .when('/editBook/:id', {
      templateUrl: '/partials/editBook',
      controller: 'EditBookCtrl'
    })
    .when('/deleteBook/:id', {
      templateUrl: '/partials/deleteBook',
      controller: 'DeleteBookCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
    return $locationProvider.html5Mode(true);
  }
]);
