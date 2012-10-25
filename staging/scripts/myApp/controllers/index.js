"use strict";

angular.module("myApp").controller("IndexCtrl", function($scope, $http, $location) {
  var formatBook;
  $scope.user = {};
  $http.get("/api/books").success(function(data) {
    $scope.books = data.books;
    $scope.user = data.user;
    return formatBook();
  });
  $scope.google_login = function() {
    return window.location = "/auth/google";
  };
  $scope.github_login = function() {
    return window.location = "/auth/github";
  };
  $scope.twitter_login = function() {
    return window.location = "/auth/twitter";
  };
  $scope.vk_login = function() {
    return window.location = "/auth/vkontakte";
  };
  $scope.logout = function() {
    return window.location = "/logout";
  };
  $scope.deleteDialog = function(book) {
    return $(".modal-" + book._id).show();
  };
  $scope.cancel = function(book) {
    return $(".modal-" + book._id).hide();
  };
  $scope.deleteBook = function(book) {
    return $http["delete"]("/api/book/" + book._id).success(function(data) {
      console.log("delete book");
      $(".modal-" + book._id).hide();
      return $http.get("/api/books").success(function(data) {
        $scope.books = data.books;
        return formatBook();
      });
    });
  };
  return formatBook = function() {
    return angular.forEach($scope.books, function(book, i) {
      book.time = TimeToString(book.readingTime, true);
      if (book.title.length > 25) {
        return book.title = book.title.substr(0, 25) + "…";
      }
    });
  };
});
