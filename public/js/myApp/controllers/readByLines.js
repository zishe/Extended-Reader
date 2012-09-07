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
  $scope.readText = '';

  $scope.prevTime = null;
  $scope.nowTime = null;
  $scope.readingTime = 0;

  var timeout;

  $http.get("/api/book_with_text/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.text = $scope.book.text;
    if ($scope.book.lastWordPos > 0){
      $scope.text = $scope.book.text.substr($scope.book.lastWordPos,
        $scope.book.text.length - 1);
    } else if ($scope.book.lastWordPos != 0){
      $scope.book.lastWordPos = 0;
    }
    $scope.book.text = null;

    console.log('open book');
    $('#time').text();

    $http.get("/api/settings").success(function(data) {
      $scope.settings = data.settings;
      console.log(data.settings);
      // setBgColor($scope);
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
      $scope.prevTime = (new Date()).getTime();
      $scope.playing = true;
      tick();
      // $scope.intervalId = setInterval($scope.change_text, 300) // использовать функцию
    }
  };

  $scope.pause = function() {
    if ($scope.playing){
      $scope.playing = false;
      $timeout.cancel(timeout);

      var count = getWordsCount($scope.readText);

      $scope.book.readingTime += Math.round($scope.readingTime);

      $scope.book.readCount.words += count.words;
      $scope.book.readCount.chars += count.chars;
      $scope.book.readCount.charsWithoutSpaces += count.charsWithoutSpaces;
      $scope.book.complete = Math.round( $scope.book.readCount.chars * 100 / $scope.book.count.chars );

      // if ($scope.text.match())
      if ($scope.book.lastWordPos == null){
        $scope.book.lastWordPos = 0;
      }
      $scope.book.lastWordPos += $scope.readText.length;
      $http.put("/api/save_stats/" + $routeParams.id, $scope.book).success(function(data) {
        console.log('stats saved');
      });
      $scope.readText = '';
      $scope.readingTime = 0;
    }
  };

  var tick = function() {
    if ($scope.num > 0){
      $scope.readText += $scope.currText + ' ';
      // $scope
    }
    $scope.currText = $scope.parts[$scope.num];
    $scope.num++;
    
    $scope.nowTime = (new Date()).getTime();
    $scope.readingTime += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;

    $('#time').text(TimeToString($scope.readingTime / 1000));

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
    angular.forEach($scope.text.replace(/[\s\n\t\r]+/gi, ' ').split(' '), function(word, num){
      $scope.curr +=  ' ' + word;
      var m = $scope.curr.match(/\S+/gi);
      if (m && (m.length >= $scope.settings.words_count || endsWithArr($scope.curr, ['.', ';']))) {
        $scope.parts.push($scope.curr.trim());
        $scope.curr = '';
      }
    });
  };

});


var getWordsCount = function(text) {
  console.log('Define words and chars count');
  var count = {};
  count.chars = text.length;
  count.charsWithoutSpaces = text.replace(/\s+/g, '').length;
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, '').replace(/\s+/gi, ' ').trim().split(' ').length;
  console.log('chars: ' + count.chars);
  console.log('chars wothout spaces: ' + count.charsWithoutSpaces);
  console.log('words count: ' + count.words);
  return count;
};
