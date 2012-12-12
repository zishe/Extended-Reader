"use strict"

# View Book
angular.module("myApp").controller "ViewBookCtrl", ($scope, $http, $routeParams) ->

  # function format(str) {
  #   var s = '';
  #   for (var i = 0; i <= str.length - 1; i++) {
  #     console.log("fdsafsda");
  #     if ( i % 3 == 0) s += str[i] + ' ';
  #     else s += str[i];
  #   };
  #   return s;
  # };

  drawGraph = ->
    if $scope.gnum > 0
      console.log "remove graph" + ($scope.gnum - 1)
      $("#graph" + ($scope.gnum - 1)).remove()
    $(".graph-block").append "<div id=\"graph" + $scope.gnum + "\"></div>"
    num = 0
    fl = true
    decimal_data = []
    while $scope.parts.length > num
      part = $scope.parts[num]
      if part.reading_time > 0
        decimal_data.push
          x: num
          y: Math.round(part.count.words / part.reading_time * 60)

      num++
    $scope.ml = Morris.Line(
      element: "graph" + $scope.gnum
      data: decimal_data
      xkey: "x"
      ykeys: ["y"]
      labels: ["Speed"]
      parseTime: false
      hideHover: true
    )
    $scope.gnum++

  $scope.book = {}
  $scope.gnum = 0
  $scope.currCount = {}

  $http.get("/api/book/" + $routeParams.id).success (data) ->
    updateData data

  updateData = (data) ->
    $scope.book = data.book
    $scope.book.createdDate = $.format.date($scope.book.created, "hh:mm d MMMM yyyy")
    $scope.book.updated = $.format.date($scope.book.updated, "hh:mm d MMMM yyyy")
    $scope.book.readTime = TimeToString($scope.book.reading_time)

    if $scope.book.reading_time > 0
      $scope.book.readingSpeed = Math.round($scope.book.read_count.words / ($scope.book.reading_time / 60)) + " words per minute"
    else
      $scope.book.readingSpeed = "undefined"

    $scope.book.count.chars = $scope.book.count.chars
    $scope.book = data.book

    $http.get("/api/parts/" + $routeParams.id).success (data) ->
      $scope.parts = data.parts
      drawGraph()
      $scope.book


  $scope.remove_page_info = (page_num) ->
    console.log page_num

    if angular.isNumber(parseInt(page_num))
      part = $scope.parts[page_num]
      console.log part.reading_time
      part.reading_time = null

      drawGraph()

      $http.put("/api/part/" + part._id, part).success (data) ->
        console.log "save null time"

    $scope.page_num = ""

  $scope.reset_data = ->
    $http.put("/api/reset_book/" + $scope.book._id).success (data) ->
      console.log "reseted"
      updateData data


  $scope.checkCount = ->
    $scope.currCount = getWordsCount($scope.textToCheck)

    console.log $scope.textToCheck
    console.log $scope.count
    $("#count").text $scope.currCount.words
