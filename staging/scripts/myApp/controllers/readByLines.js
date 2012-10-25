"use strict";

var getWordsCount;

angular.module("myApp").controller("ReadByLinesCtrl", function($scope, $http, $routeParams, $timeout) {
  var collect_parts, reset_parts, setWordsFont, tick, timeout;
  $scope.book = {};
  $scope.settings = {};
  $scope.showOpts = false;
  $scope.playing = false;
  $scope.parts = [];
  $scope.curr = "";
  $scope.currText = "";
  $scope.num = 0;
  $scope.readText = "";
  $scope.prevTime = null;
  $scope.nowTime = null;
  $scope.readingTime = 0;
  timeout = void 0;
  $http.get("/api/book_with_text/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.text = $scope.book.text;
    if ($scope.book.lastWordPos > 0) {
      $scope.text = $scope.book.text.substr($scope.book.lastWordPos, $scope.book.text.length - 1);
    } else {
      if ($scope.book.lastWordPos !== 0) {
        $scope.book.lastWordPos = 0;
      }
    }
    $scope.book.text = null;
    console.log("open book");
    $("#time").text();
    return $http.get("/api/settings").success(function(data) {
      var changed;
      $scope.settings = data.settings;
      console.log(data.settings);
      setWordsFont($scope);
      changed = false;
      if ($scope.settings.words_font_size == null) {
        $scope.settings.words_font_size = 20;
        changed = true;
      }
      if ($scope.settings.words_count == null) {
        $scope.settings.words_count = 3;
        changed = true;
      }
      if ($scope.settings.show_delay < 100) {
        $scope.settings.show_delay = 300;
        changed = true;
      }
      if (changed) {
        saveSettings($scope, $http);
      }
      return collect_parts($scope);
    });
  });
  $scope.play = function() {
    if (!$scope.playing) {
      $scope.prevTime = (new Date()).getTime();
      $scope.playing = true;
      return tick();
    }
  };
  $scope.pause = function() {
    var count;
    if ($scope.playing) {
      $scope.playing = false;
      $timeout.cancel(timeout);
      count = getWordsCount($scope.readText);
      $scope.book.readingTime += Math.round($scope.readingTime / 1000);
      $scope.book.readCount.words += count.words;
      $scope.book.readCount.chars += count.chars;
      $scope.book.readCount.charsWithoutSpaces += count.charsWithoutSpaces;
      $scope.book.complete = Math.round($scope.book.readCount.chars * 100 / $scope.book.count.chars);
      if ($scope.book.lastWordPos == null) {
        $scope.book.lastWordPos = 0;
      }
      $scope.book.lastWordPos += $scope.readText.length;
      $http.put("/api/save_stats/" + $routeParams.id, $scope.book).success(function(data) {
        return console.log("stats saved");
      });
      $scope.readText = "";
      return $scope.readingTime = 0;
    }
  };
  tick = function() {
    var extra_lngth, extra_time;
    if ($scope.num > 0) {
      $scope.readText += $scope.currText + " ";
    }
    $scope.currText = $scope.parts[$scope.num];
    $scope.num++;
    $scope.nowTime = (new Date()).getTime();
    $scope.readingTime += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;
    $("#time").text(TimeToString($scope.readingTime / 1000));
    extra_lngth = $scope.currText.length - $scope.settings.words_count * 7;
    extra_time = (extra_lngth > 0 ? Math.round(extra_lngth / 5) : 0);
    console.log(extra_time);
    return timeout = $timeout(tick, $scope.settings.show_delay + extra_time);
  };
  $scope.change_text = function() {
    $("#text").text($scope.parts[$scope.num]);
    return $scope.num++;
  };
  $scope.font_increase = function() {
    $scope.settings.words_font_size++;
    return setWordsFont($scope);
  };
  $scope.font_decrease = function() {
    if ($scope.settings.words_font_size > 1) {
      $scope.settings.words_font_size--;
      return setWordsFont($scope);
    }
  };
  $scope.words_increase = function() {
    $scope.settings.words_count++;
    return reset_parts($scope);
  };
  $scope.words_decrease = function() {
    if ($scope.settings.words_count > 1) {
      $scope.settings.words_count--;
      return reset_parts($scope);
    }
  };
  $scope.dalay_increase = function() {
    return $scope.settings.show_delay += 100;
  };
  $scope.dalay_decrease = function() {
    if ($scope.settings.show_delay > 100) {
      return $scope.settings.show_delay -= 100;
    }
  };
  $scope.save_settings = function() {
    return saveSettings($scope, $http);
  };
  setWordsFont = function() {
    $("#text").css("font-size", $scope.settings.words_font_size + "px");
    return $("#text").css("line-height", ($scope.settings.words_font_size + 10) + "px");
  };
  reset_parts = function() {
    $scope.parts = [];
    return collect_parts($scope);
  };
  return collect_parts = function() {
    return angular.forEach($scope.text.replace(/[\s\n\t\r]+/g, " ").split(" "), function(word, num) {
      var m;
      $scope.curr += " " + word;
      m = $scope.curr.match(/\S+/g);
      if (m && (m.length >= $scope.settings.words_count || endsWithArr($scope.curr, [".", ";"]))) {
        $scope.parts.push($scope.curr.trim());
        return $scope.curr = "";
      }
    });
  };
});

getWordsCount = function(text) {
  var count;
  console.log("Define words and chars count");
  count = {};
  count.chars = text.length;
  count.charsWithoutSpaces = text.replace(/\s+/g, "").length;
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, "").replace(/\s+/g, " ").trim().split(" ").length;
  console.log("chars: " + count.chars);
  console.log("chars wothout spaces: " + count.charsWithoutSpaces);
  console.log("words count: " + count.words);
  return count;
};
