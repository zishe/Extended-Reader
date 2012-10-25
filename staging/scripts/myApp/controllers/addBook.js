"use strict";

angular.module("myApp").controller("AddBookCtrl", function($scope, $http, $location) {
  $scope.book = {};
  $scope.save = function() {
    return $http.post("/api/book", $scope.book).success(function(data) {
      console.log(data.book);
      return $location.path("/book/" + data.book._id);
    });
  };
  return $scope.cancel = function() {
    return $location.path("/");
  };
});
