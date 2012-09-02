"use strict";

//  Index
angular.module('myApp').controller('IndexCtrl', function($scope, $http, $location) {
  $scope.user = {};

  $http.get("/api/books").success(function(data) {
    $scope.books = data.books;
    $scope.user = data.user;
    formatBook();
  });

  $scope.google_login = function() {
    window.location = "/auth/google";
  };

  $scope.github_login = function() {
    window.location = "/auth/github";
  };

  $scope.twitter_login = function() {
    window.location = "/auth/twitter";
  };

  $scope.vk_login = function() {
    window.location = "/auth/vkontakte";
  };

  $scope.logout = function() {
    window.location = "/logout";
  };

  $scope.deleteDialog = function(book) {
    $('.modal-' + book._id).show();
  };

  $scope.cancel = function(book) {
    $('.modal-' + book._id).hide();
  };

  $scope.deleteBook = function(book) {
    $http["delete"]('/api/book/' + book._id).success(function(data) {
      console.log('delete book');
      $('.modal-' + book._id).hide();

      $http.get("/api/books").success(function(data) {
        $scope.books = data.books;
        formatBook();
      });
    });
  };

  var formatBook = function() {
    angular.forEach($scope.books, function(book, i){
      book.time = TimeToString(book.readingTime, true);
      if (book.title.length > 25) book.title = book.title.substr(0, 25) + '…'
    });
  };


});