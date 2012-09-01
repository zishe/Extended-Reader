"use strict";

// View Book
angular.module('myApp').controller('ViewBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  
  return $http.get("/api/book/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    
    $scope.book.createdDate = $.format.date($scope.book.created, "dd MMMM yyyy");
    $scope.book.readTime = TimeToString($scope.book.readingTime);
    $scope.book = data.book;

    $http.get('/api/book_parts/' + $routeParams.id).success(function(data) {
      $scope.parts = data.parts
      getGraph($scope);
      return $scope.book;
    });
  });
});


function getGraph($scope) {
  var num = 0;
  var fl = true;
  var decimal_data = [];
  while ($scope.parts.length > num){
    var part = $scope.parts[num];
      if (part.readingTime != null){
      decimal_data.push({
        x: num,
        y: Math.round(part.count.words / part.readingTime * 60)
      });
    }
    num++;
  }
  console.log(decimal_data);

  Morris.Line({
    element: 'graph',
    data: decimal_data,
    xkey: 'x',
    ykeys: ['y'],
    labels: ['Speed'],
    parseTime: false,
    hideHover: true
    
  });
};
