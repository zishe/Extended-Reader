"use strict";

// Add Book
angular.module('myApp').controller('AddBookCtrl', function($scope, $http, $location) {
  $scope.book = {};
  $scope.save = function() {
    return $http.post("/api/book", $scope.book).success(function(data) {
      return $location.path("/");
    });
  };

  return $scope.cancel = function() {
    return $location.path("/");
  };
});

