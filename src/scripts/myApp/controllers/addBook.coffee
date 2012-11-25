"use strict"

# Add Book
angular.module("myApp").controller "AddBookCtrl", ($scope, $http, $location) ->
  $scope.book = {}
  $scope.save = ->
    $http.post("/api/book", $scope.book).success (data) ->
      console.log data.book
      $location.path "/book/" + data.book._id


  $scope.cancel = ->
    $location.path "/"
