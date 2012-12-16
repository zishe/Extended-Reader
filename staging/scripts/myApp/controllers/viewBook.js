"use strict";

angular.module("myApp").controller("ViewBookCtrl", function($scope, $http, $routeParams) {
  var drawGraph, updateData;
  drawGraph = function() {
    var decimal_data, fl, num, part;
    if ($scope.gnum > 0) {
      console.log("remove graph" + ($scope.gnum - 1));
      $("#graph" + ($scope.gnum - 1)).remove();
    }
    $(".graph-block").append("<div id=\"graph" + $scope.gnum + "\"></div>");
    num = 0;
    fl = true;
    decimal_data = [];
    while ($scope.parts.length > num) {
      part = $scope.parts[num];
      if (part.reading_time > 0) {
        decimal_data.push({
          x: num,
          y: Math.round(part.count.words / part.reading_time * 60)
        });
      }
      num++;
    }
    $scope.ml = Morris.Line({
      element: "graph" + $scope.gnum,
      data: decimal_data,
      xkey: "x",
      ykeys: ["y"],
      labels: ["Speed"],
      parseTime: false,
      hideHover: true
    });
    return $scope.gnum++;
  };
  $scope.book = {};
  $scope.gnum = 0;
  $scope.currCount = {};
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    return updateData(data);
  });
  updateData = function(data) {
    $scope.book = data.book;
    $scope.book.created = $.format.date($scope.book.created_at, "hh:mm d MMMM yyyy");
    $scope.book.updated = $.format.date($scope.book.updated_at, "hh:mm d MMMM yyyy");
    $scope.book.readTime = TimeToString($scope.book.reading_time);
    if ($scope.book.reading_time > 0) {
      $scope.book.readingSpeed = Math.round($scope.book.read_count.words / ($scope.book.reading_time / 60)) + " words per minute";
    } else {
      $scope.book.readingSpeed = "undefined";
    }
    $scope.book.count.chars = $scope.book.count.chars;
    $scope.book = data.book;
    return $http.get("/api/parts/" + $routeParams.id).success(function(data) {
      $scope.parts = data.parts;
      drawGraph();
      return $scope.book;
    });
  };
  $scope.remove_page_info = function(page_num) {
    var part;
    console.log(page_num);
    if (angular.isNumber(parseInt(page_num))) {
      part = $scope.parts[page_num];
      console.log(part.reading_time);
      part.reading_time = null;
      drawGraph();
      $http.put("/api/part/" + part._id, part).success(function(data) {
        return console.log("save null time");
      });
    }
    return $scope.page_num = "";
  };
  $scope.reset_data = function() {
    return $http.put("/api/reset_book/" + $scope.book._id).success(function(data) {
      console.log("reseted");
      return updateData(data);
    });
  };
  return $scope.checkCount = function() {
    $scope.currCount = getWordsCount($scope.textToCheck);
    console.log($scope.textToCheck);
    console.log($scope.count);
    return $("#count").text($scope.currCount.words);
  };
});
