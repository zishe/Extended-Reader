"use strict";

angular.module('myApp').controller('ReadBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.settings = {};
  $scope.part = {};

  $scope.prevTime = null;
  $scope.nowTime = null;
  $scope.readingTime = 0;

  $scope.allTime = 0;
  $scope.readWords = 0;

  $scope.playing = false;
  $scope.showOpts = false;
  
  $http.get("/api/readBook/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.settings = data.settings;
    $scope.part = data.part;
    console.log($scope.part);
    
    if (data.part == null || $scope.book.finished){
      $('#text').html("<p>The end</p>");
      setAll($scope);
      console.log('end of text');
    }
    else{
      $('#text').html('<p>' + $scope.part.text.replace(/\n/g, '</p><p>') + '</p>');
      setAll($scope);
    }
  });

  
  $scope.next = function() {
    if ($scope.readingTime != 0) {
      console.log('save time');
      $scope.part.readingTime = Math.round($scope.readingTime / 1000);
      $http.put("/api/part/" + $scope.part._id, $scope.part).success(function(data) {
        console.log('saved');
      });
      $scope.readingTime = 0;
      $scope.prevTime = (new Date()).getTime();
    }
    // $scope.book.complete = Math.round($scope.book.parts[$scope.book.partNum].startPos * 100 / $scope.book.count.chars);

    // angular.forEach($scope.book.parts, function(part, num){
    //   if (part.allTime != null)
    //     $scope.allTime += part.allTime;
    // });
    if ($scope.part.readingTime != null)
      $scope.book.readingTime += $scope.part.readingTime;

    // var i = 0;
    // angular.forEach($scope.book.parts, function(part, num){
    //   if (i < $scope.book.partNum) {
    //       $scope.readWords += part.countWords;
    //       i++;
    //     }
    // });
    // $scope.book.readWords = $scope.readWords;

    $scope.book.readCount.words += $scope.part.count.words;
    $scope.book.readCount.chars += $scope.part.count.chars;
    $scope.book.readCount.charsWithoutSpaces += $scope.part.count.charsWithoutSpaces;
    $scope.book.complete = Math.round( $scope.book.readCount.chars * 100 / $scope.book.count.chars );

    $scope.book.currPartNum++;

    $http.put('/api/save_book/' + $routeParams.id, $scope.book).success(function(data) {
      console.log('next');
      console.log(data.part);
      if (data.part == null){
        $scope.book.finished = true;
        $http.put('/api/book_finished/' + $routeParams.id).success(function(data) {
          console.log('save finishing book');
        });
        $('#text').html("<p>The end</p>");
        setAll($scope);
        console.log('end of text');
      }
      else{
        $scope.part = data.part;
        $('#text').html('<p>' + $scope.part.text.replace(/\n/g, '</p><p>') + '</p>');
        setAll($scope);
      }
    });
  };

  $scope.prev = function() {
    if ($scope.book.partNum > 0) {
      $scope.book.partNum = $scope.book.partNum - 1;
      setPart($scope);
        
      $http.put("/api/setnum/" + $routeParams.id + '/' + $scope.book.partNum).success(function(data) {
        console.log('save part num');
      });
      setAll($scope);
    }
  };


  $scope.play = function() {
    if (!$scope.playing){
      $scope.playing = true;
      $scope.prevTime = (new Date()).getTime();
      $scope.intervalId = setInterval($scope.sec, 1000) // использовать функцию
    }
  };

  $scope.pause = function() {
    if ($scope.playing){
      $scope.playing = false;
      $scope.sec();
      clearInterval($scope.intervalId);
    }
  };

  $scope.sec = function() {
    $scope.nowTime = (new Date()).getTime();
    $scope.readingTime += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;

    console.log($scope.readingTime);
    $('#time').text(TimeToString($scope.readingTime / 1000));
  }



  $scope.font_increase = function() {
    $scope.settings.font_size++;
    setFont($scope);
  };

  $scope.font_decrease = function() {
    if ($scope.settings.font_size > 0) {
      $scope.settings.font_size--;
      setFont($scope);
    }
  };

  $scope.line_increase = function() {
    $scope.settings.line_height++;
    setLineHeight($scope);
  };

  $scope.line_decrease = function() {
    if ($scope.settings.line_height > 0) {
      $scope.settings.line_height--;
      setLineHeight($scope);
    }
  };

  $scope.width_increase = function() {
    $scope.settings.width += 20;
    setWidth($scope);
  };

  $scope.width_decrease = function() {
    if ($scope.settings.width > 0) {
      $scope.settings.width -= 20;
      setWidth($scope);
    }
  };

  $scope.part_increase = function() {
    $scope.settings.part_length += 100;
    ResetParts($scope, $http);
  };

  $scope.part_decrease = function() {
    if (parseInt($scope.settings.part_length) > 0) {
      $scope.settings.part_length -= 100;
      ResetParts($scope, $http);
    }
  };

  $scope.save_settings = function() {
    saveSettings($scope, $http);
  };

});



function saveSettings($scope, $http) {
  console.log($scope.settings);
  $http.post("/api/settings/" + $scope.settings._id, $scope.settings).success(function(data) {
    console.log(data);
    console.log('settings saved');
  });
};

function ResetParts($scope, $http) {
  // $http.post("/api/reset_parts/" + $scope.book._id + '/' + scope.settings.part_length).success(function(data) {
  
  // });
};




function setAll($scope) {
  setBgColor($scope);
  setFont($scope);
  setLineHeight($scope);
  setWidth($scope);
  $('html, body').animate({
    scrollTop: $('#btn-next').offset().top
    }, 300
  );
};


function setBgColor($scope) {
  $('body').css("background-color", '#E5E8D3');
};

function setWidth($scope) {
  // console.log('set width : ' + $scope.settings.width + 'px');
  $('.reading-block').each(function() {
    $(this).css("width", $scope.settings.width + 'px');
  });
};

function setFont($scope) {
  setCssProp("font-size", $scope.settings.font_size + 'px');
};

function setLineHeight($scope) {
  setCssProp("line-height", $scope.settings.line_height + 'px');
};

function setCssProp(name, val) {
  // console.log('set css: ' + name + " : " + val);
  $('.reading-area p').each(function() {
    $(this).css(name, val);
  });
};


function TimeToString(time, brief) {
  var sec = Math.round(time % 60);
  var min = Math.round(((time - (time % 60))/ 60));
  var hour = Math.round(((time - (time % 3600))/ 3600));
  var text = '';
  
  if (hour == 1)
    text = text + hour + ' hour ';
  if (hour > 1)
    text = text + hour + ' hours ';

  if (min == 1)
    text = text + min + ' minute ';
  if (min > 1)
    text = text + min + ' minutes ';

  if (sec < 2)
    text = text + sec + ' second';
  if (sec > 1)
    text = text + sec + ' seconds';

  if (brief) text = text.replace(/minute(s)*/g, ':').replace(/second(s)*/g, '').replace(/\s+/g, '');
  return text;
};