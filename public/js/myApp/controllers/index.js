"use strict";

//  Index
angular.module('myApp').controller('IndexCtrl', function($scope, $http) {
  $http.get("/api/books").success(function(data, status, headers, config) {
    $scope.books = data.books;
    angular.forEach($scope.books, function(book, i){
      book.time = TimeToString(book.readingTime, true);
      if (book.title.length > 25) book.title = book.title.substr(0, 25) + '…'
    });
  });
});