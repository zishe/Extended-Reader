"use strict";

// View Book
angular.module('myApp').controller('ViewBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.gnum = 0;
  
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    
    $scope.book.createdDate = $.format.date($scope.book.created, "hh:mm d MMMM yyyy");
    $scope.book.lastUse = $.format.date($scope.book.lastUse, 'hh:mm d MMMM yyyy');
    $scope.book.readTime = TimeToString($scope.book.readingTime);
    if ($scope.book.readingTime > 0)
      $scope.book.readingSpeed = Math.round($scope.book.readCount.words/($scope.book.readingTime/60)) + ' words per minute';
    else
      $scope.book.readingSpeed = 'undefined';
    $scope.book.count.chars = $scope.book.count.chars;

    $scope.book = data.book;

    $http.get('/api/parts/' + $routeParams.id).success(function(data) {
      $scope.parts = data.parts
      drawGraph();
      $scope.book;
    });
  });

  $scope.remove_page_info = function(page_num) {
    console.log(page_num);
    if (angular.isNumber(parseInt(page_num))){
      var part = $scope.parts[page_num];
      console.log(part.readingTime);
      part.readingTime = null;
      drawGraph();

      $http.put("/api/part/" + part._id, part).success(function(data) {
        console.log('save null time');
      });

    }
    $scope.page_num = '';
  };

  $scope.reset_data = function() {
    $http.put("/api/reset_book/" + $scope.book._id).success(function(data) {
      $scope.book = data.book;
      console.log('reseted');
    });
  };

  // function format(str) {
  //   var s = '';
  //   for (var i = 0; i <= str.length - 1; i++) {
  //     console.log("fdsafsda");
  //     if ( i % 3 == 0) s += str[i] + ' ';
  //     else s += str[i];
  //   };
  //   return s;
  // };


  function drawGraph() {
    if ($scope.gnum > 0){
      console.log('remove graph' + ($scope.gnum - 1));
      $('#graph' + ($scope.gnum - 1)).remove();
    }
    $('.graph-block').append('<div id="graph' + $scope.gnum + '"></div>')
    
    var num = 0;
    var fl = true;
    var decimal_data = [];
    while ($scope.parts.length > num){
      var part = $scope.parts[num];
        if (part.readingTime > 0){
        decimal_data.push({
          x: num,
          y: Math.round(part.count.words / part.readingTime * 60)
        });
      }
      num++;
    }

    $scope.ml = Morris.Line({
      element: 'graph' + $scope.gnum,
      data: decimal_data,
      xkey: 'x',
      ykeys: ['y'],
      labels: ['Speed'],
      parseTime: false,
      hideHover: true
    });
    $scope.gnum++;
  };

});
