"use strict"

# Edit Book
angular.module("myApp").controller "EditBookCtrl", ($scope, $http, $location, $routeParams) ->
  $scope.book = {}
  $http.get("/api/book_with_text/" + $routeParams.id).success (data) ->
    $scope.book = data.book

  $scope.save = ->
    $http.put("/api/book/" + $routeParams.id, $scope.book).success (data) ->
      $location.url "/readBook/" + $routeParams.id

  $scope.cancel = ->
    $location.path "/"
