"use strict";

angular.module('myApp').controller('ReadByLinesCtrl', function($scope, $http, $routeParams, $timeout) {
  $scope.book = {};
  $scope.settings = {};
  $scope.showOpts = false;
  $scope.playing = false;
  $scope.parts = [];
  $scope.curr = '';
  $scope.currText = '';
  $scope.num = 0;
  var timeout;

  $http.get("/api/book_with_text/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    console.log('open book');

    $http.get("/api/settings").success(function(data) {
      $scope.settings = data.settings;
      console.log(data.settings);
      setBgColor($scope);
      setWordsFont($scope);
      
      var changed = false;
      if ($scope.settings.words_font_size == null){
        $scope.settings.words_font_size = 20;
        changed = true;
      }
      if ($scope.settings.words_count == null){
        $scope.settings.words_count = 3;
        changed = true;
      }
      if (changed) saveSettings($scope, $http);
      
      collect_parts($scope);
      //$('#text').text("Pull play to start");
    });
  });

  $scope.play = function() {
    if (!$scope.playing){
      $scope.playing = true;
      tick();
      // $scope.intervalId = setInterval($scope.change_text, 300) // использовать функцию
    }
  };

  $scope.pause = function() {
    if ($scope.playing){
      $scope.playing = false;
      $timeout.cancel(timeout);
      // $scope.change_text();
      // clearInterval($scope.intervalId);
    }
  };

  var tick = function() {
    $scope.currText = $scope.parts[$scope.num];
    $scope.num++;
    timeout = $timeout(tick, 300);
  };


  $scope.change_text = function() {
    $('#text').text($scope.parts[$scope.num]);
    $scope.num++;
  }

  $scope.font_increase = function() {
    $scope.settings.words_font_size++;
    setWordsFont($scope);
  };

  $scope.font_decrease = function() {
    if ($scope.settings.words_font_size > 1) {
      $scope.settings.words_font_size--;
      setWordsFont($scope);
    }
  };

  $scope.words_increase = function() {
    $scope.settings.words_count++;
    reset_parts($scope)
  };

  $scope.words_decrease = function() {
    if ($scope.settings.words_count > 1) {
      $scope.settings.words_count--;
      reset_parts($scope)
    }
  };

  $scope.save_settings = function() {
    saveSettings($scope, $http);
  };

  var setWordsFont = function() {
    $('#text').css('font-size', $scope.settings.words_font_size + 'px');
    $('#text').css('line-height', ($scope.settings.words_font_size + 10)+ 'px');
  };

  var reset_parts = function() {
    $scope.parts = [];
    collect_parts($scope);
  };

  var collect_parts = function() {
    angular.forEach($scope.book.text.replace(/[\s\n\t\r]+/gi, ' ').split(' '), function(word, num){
      $scope.curr +=  ' ' + word;
      var m = $scope.curr.match(/\S+/gi);
      if (m && (m.length >= $scope.settings.words_count || endsWithArr($scope.curr, ['.', ';']))) {
        $scope.parts.push($scope.curr.trim());
        $scope.curr = '';
      }
    });
  };

});
