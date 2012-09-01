"use strict";

// Delete Book
angular.module('myApp').controller('DeleteBookCtrl', function($scope, $http, $location, $routeParams) {
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    return $scope.book = data.book;
  });
  $scope.delete = function() {
    $http["delete"]('/api/book/' + $routeParams.id).success(function(data) {
      $location.url("/");
    });
  };
  return $scope.cancel = function() {
    return $location.path("/");
  };
});
