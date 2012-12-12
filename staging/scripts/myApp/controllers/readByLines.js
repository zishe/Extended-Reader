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
  $scope.reading_time = 0;
  timeout = void 0;
  $http.get("/api/book_with_text/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.text = data.book.text;
    if ($scope.book.last_word_pos > 0) {
      $scope.text = $scope.book.text.substr($scope.book.last_word_pos, $scope.book.text.length - 1);
    } else {
      if ($scope.book.last_word_pos !== 0) {
        $scope.book.last_word_pos = 0;
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
      if ($scope.settings.words_delay < 100) {
        $scope.settings.words_delay = 300;
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
      $scope.book.reading_time += Math.round($scope.reading_time / 1000);
      $scope.book.read_count.words += count.words;
      $scope.book.read_count.chars += count.chars;
      $scope.book.read_count.chars_without_spaces += count.chars_without_spaces;
      $scope.book.complete = Math.round($scope.book.read_count.chars * 100 / $scope.book.count.chars);
      if ($scope.book.last_word_pos == null) {
        $scope.book.last_word_pos = 0;
      }
      $scope.book.last_word_pos += $scope.readText.length;
      $http.put("/api/save_stats/" + $routeParams.id, $scope.book).success(function(data) {
        return console.log("stats saved");
      });
      $scope.readText = "";
      return $scope.reading_time = 0;
    }
  };
  tick = function() {
    var showing_time;
    if ($scope.num > 0) {
      $scope.readText += $scope.currText + " ";
    }
    $scope.currText = $scope.parts[$scope.num];
    $scope.num++;
    $scope.nowTime = (new Date()).getTime();
    $scope.reading_time += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;
    $("#time").text(TimeToString($scope.reading_time / 1000));
    showing_time = ($scope.currText.length / ($scope.settings.words_speed * 7 / 60)) * 1000;
    return timeout = $timeout(tick, showing_time);
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
  $scope.length_increase = function() {
    $scope.settings.words_length++;
    return reset_parts($scope);
  };
  $scope.length_decrease = function() {
    if ($scope.settings.words_length > 1) {
      $scope.settings.words_length--;
      return reset_parts($scope);
    }
  };
  $scope.dalay_increase = function() {
    return $scope.settings.words_delay += 30;
  };
  $scope.dalay_decrease = function() {
    if ($scope.settings.words_delay > 50) {
      return $scope.settings.words_delay -= 30;
    }
  };
  $scope.speed_increase = function() {
    return $scope.settings.words_speed += 5;
  };
  $scope.speed_decrease = function() {
    if ($scope.settings.words_speed > 50) {
      return $scope.settings.words_speed -= 5;
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
      $scope.curr += " " + word;
      if ($scope.curr.length >= $scope.settings.words_length || endsWithArr($scope.curr, [".", ";", "...", "...", "?", "!"])) {
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
  count.chars_without_spaces = text.replace(/\s+/g, "").length;
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, "").replace(/\s+/g, " ").trim().split(" ").length;
  console.log("chars: " + count.chars);
  console.log("chars wothout spaces: " + count.chars_without_spaces);
  console.log("words count: " + count.words);
  return count;
};
