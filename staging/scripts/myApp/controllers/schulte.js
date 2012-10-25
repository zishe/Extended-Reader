"use strict";

angular.module("myApp").controller("SchulteCtrl", function($scope, $http, $location, $timeout) {
  var init_arr, odd, tick, timeout;
  $scope.size = 5;
  $scope.all = 25;
  $scope.arr = [];
  $scope.num = 1;
  $scope.playing = false;
  timeout = void 0;
  odd = false;
  $scope.init = function() {
    return init_arr($scope);
  };
  init_arr = function($scope) {
    var arr, count, i;
    arr = [];
    count = Math.pow($scope.size, 2);
    odd = $scope.size % 2 === 1;
    if (odd) {
      count--;
    }
    i = count;
    while (i > 0) {
      arr.push(i);
      i--;
    }
    arr.shuffle();
    console.log(arr);
    if (odd) {
      arr.insert(count / 2, "");
    }
    $scope.all = count;
    return $scope.arr = arr;
  };
  $scope.set_size = function(n) {
    $scope.size = n;
    $(".play-field").removeClass("play-field-4").removeClass("play-field-5").removeClass("play-field-6");
    if (n === 4) {
      $(".play-field").addClass("play-field-4");
    }
    if (n === 5) {
      $(".play-field").addClass("play-field-5");
    }
    if (n === 6) {
      $(".play-field").addClass("play-field-6");
    }
    return $scope.init();
  };
  $scope.start = function() {
    init_arr($scope);
    $('.start').text('Restart');
    return $scope.play();
  };
  $scope.cancel = function() {
    $scope.refresh();
    return $('.start').text('Start');
  };
  $scope.turn = function(n) {
    var p;
    p = $("#" + n).text();
    if (p - $scope.num === 0) {
      console.log('right num!');
      if ($scope.num === $scope.all) {
        return $scope.refresh();
      } else {
        $scope.num++;
        console.log($scope.num);
        return $(".currNum").text($scope.num);
      }
    }
  };
  $scope.play = function() {
    console.log($scope.playing);
    if (!$scope.playing) {
      $scope.startTime = (new Date()).getTime();
      $scope.playing = true;
      console.log("playing");
      return tick();
    }
  };
  $scope.refresh = function() {
    $(".cicle").css("background-color", "green");
    $scope.num = 1;
    $scope.playing = false;
    return $timeout.cancel(timeout);
  };
  return tick = function() {
    $scope.time = (new Date()).getTime() - $scope.startTime;
    $("#time").text(($scope.time / 1000).toFixed(1));
    return timeout = $timeout(tick, 100);
  };
});

Array.prototype.shuffle = function(b) {
  var i, j, t;
  i = this.length;
  j = void 0;
  t = void 0;
  while (i) {
    j = Math.floor((i--) * Math.random());
    t = (b && typeof this[i].shuffle !== "undefined" ? this[i].shuffle() : this[i]);
    this[i] = this[j];
    this[j] = t;
  }
  return this;
};

Array.prototype.insert = function(index, item) {
  return this.splice(index, 0, item);
};
