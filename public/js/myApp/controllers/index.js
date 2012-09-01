"use strict";

//  Index
angular.module('myApp').controller('IndexCtrl', function($scope, $http, $location) {
  $http.get("/api/books").success(function(data) {
    $scope.books = data.books;
    formatBook();
  });
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