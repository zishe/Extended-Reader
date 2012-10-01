"use strict";

// Add Book
angular.module('myApp').controller('SchulteCtrl', function($scope, $http, $location, $timeout) {
  $scope.size = 4;
  $scope.all = 16;
  $scope.arr = [];
  $scope.num = 1;

  $scope.playing = false;
  $scope.start = null;
  var timeout;
  var odd = false;

  $scope.init = function() {
    init_arr($scope);
    // var arr = [];
    // var count = Math.pow($scope.size, 2);
    // console.log(count);
    // if ($scope.size % 2 == 1) {
    //   odd = true;
    //   count--;
    //   console.log("even " + count);
    // }
    // for (var i = count; i > 0; i--) {
    //   arr.push(i);
    // };
    // arr.shuffle();
    // $scope.arr = arr;
  };

  var init_arr = function($scope) {
    var arr = [];
    var count = Math.pow($scope.size, 2);
    if ($scope.size % 2 == 1) {
      odd = true;
      count--;
      console.log("even " + count);
    }
    var pre_arr = [];
    for (var i = count; i > 0; i--) {
      pre_arr.push(i);
    };
    pre_arr.shuffle();
    console.log(pre_arr);

    for (var i = count - 1; i >= 0; i--) {
      if (!odd){
        arr.push(pre_arr[i]);
      } else{
        if (count / 2 == i){
          arr.push(pre_arr[i]);
          arr.push('');
        }
        else{
          console.log("even");
          arr.push(pre_arr[i]);
        }
      }
    };
    $scope.all = count;
    $scope.arr = arr;
    console.log(arr);
  };

  $scope.set_size = function() {
    $scope.size = 5;
    $('.play-field').removeClass('play-field').addClass('play-field-5');
    $scope.init();
  };

  $scope.start = function() {
    init_arr($scope);
    $scope.play();
  };

  $scope.turn = function(n) {
    console.log("turn");
    var p = $('#' + n).text();
    console.log(p);
    if (p == $scope.num){
      if ($scope.num == $scope.all){
        $('.cicle').css('background-color', 'green');
        $scope.num = 1;
        $scope.playing = false;
        $timeout.cancel(timeout);
      } else {
        $scope.num++;
        $('.currNum').text($scope.num);
      }
    }
  };

  $scope.play = function() {
    if (!$scope.playing){
      $scope.start = (new Date()).getTime();
      $scope.playing = true;
      console.log("playing");
      tick();
    }
  };

  var tick = function() {
    $scope.time = (new Date()).getTime() - $scope.start;
    $('#time').text(($scope.time / 1000).toFixed(1));
    timeout = $timeout(tick, 100);
  };


});

Array.prototype.shuffle = function( b )
{
 var i = this.length, j, t;
 while( i ) 
 {
  j = Math.floor( ( i-- ) * Math.random() );
  t = b && typeof this[i].shuffle!=='undefined' ? this[i].shuffle() : this[i];
  this[i] = this[j];
  this[j] = t;
 }

 return this;
};
