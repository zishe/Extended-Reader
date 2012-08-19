'use strict';

angular.module('myApp', ['myApp.filters', 'myApp.services', 'myApp.directives']).config([
  '$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider
    .when('/', {
      templateUrl: '/partials/index',
      controller: 'IndexCtrl'
    })
    .when('/book/:id', {
      templateUrl: '/partials/readBook',
      controller: 'ReadBookCtrl'
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

// KeyboardJS.bind.key('space', function() {
//     $(this).click();
//   }, function() {  }
// );

Mousetrap.bind('space', function() {
  console.log('space');
  $('#btn-next').click();
});

Mousetrap.bind('right', function() {
  console.log('right');
  $('#btn-next').click();
});

Mousetrap.bind('left', function() {
  console.log('left');
  $('#btn-prev').click();
});
