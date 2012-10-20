"use strict"

#  Index
angular.module("myApp").controller "IndexCtrl", ($scope, $http, $location) ->
  $scope.user = {}
  
  $http.get("/api/books").success (data) ->
    $scope.books = data.books
    $scope.user = data.user
    formatBook()

  $scope.google_login = ->
    window.location = "/auth/google"

  $scope.github_login = ->
    window.location = "/auth/github"

  $scope.twitter_login = ->
    window.location = "/auth/twitter"

  $scope.vk_login = ->
    window.location = "/auth/vkontakte"

  $scope.logout = ->
    window.location = "/logout"

  $scope.deleteDialog = (book) ->
    $(".modal-" + book._id).show()

  $scope.cancel = (book) ->
    $(".modal-" + book._id).hide()

  $scope.deleteBook = (book) ->
    $http["delete"]("/api/book/" + book._id).success (data) ->
      console.log "delete book"
      $(".modal-" + book._id).hide()
      $http.get("/api/books").success (data) ->
        $scope.books = data.books
        formatBook()

  formatBook = ->
    angular.forEach $scope.books, (book, i) ->
      book.time = TimeToString(book.readingTime, true)
      book.title = book.title.substr(0, 25) + "…"  if book.title.length > 25
