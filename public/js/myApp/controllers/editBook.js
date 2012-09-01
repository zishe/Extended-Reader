"use strict";

// Edit Book
angular.module('myApp').controller('EditBookCtrl', function($scope, $http, $location, $routeParams) {
  $scope.book = {};
  $http.get("/api/book_with_text/" + $routeParams.id).success(function(data) {
    return $scope.book = data.book;
  });
  $scope.save = function() {
    return $http.put("/api/book/" + $routeParams.id, $scope.book).success(function(data) {
      return $location.url("/readBook/" + $routeParams.id);
    });
  };
  return $scope.cancel = function() {
    return $location.path("/");
  };
});
