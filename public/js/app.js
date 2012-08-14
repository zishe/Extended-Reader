'use strict';

angular.module('myApp', ['ui', 'myApp.filters', 'myApp.services', 'myApp.directives']).config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider
    .when('/', {
      templateUrl: '/partials/index',
      controller: 'IndexCtrl'
    })
    .when('/addBook', {
      templateUrl: '/partials/addBook',
      controller: 'AddBookCtrl'
    })
    .when('/book/:id', {
      templateUrl: '/partials/viewBook',
      controller: 'ReadBookCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
    return $locationProvider.html5Mode(true);
  }
]);
