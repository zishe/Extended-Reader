var ResetParts, TimeToString, saveSettings, setAll, setCssProp, setFont, setLineHeight, setWidth;

saveSettings = function($scope, $http) {
  console.log($scope.settings);
  return $http.put("/api/settings/" + $scope.settings._id, $scope.settings).success(function(data) {
    console.log(data);
    return console.log("settings saved");
  });
};

ResetParts = function($scope, $http) {
  return $http.post("/api/reset_parts/" + $scope.book._id + "/" + $scope.settings.part_length).success(function(data) {});
};

setAll = function($scope) {
  setFont($scope);
  setLineHeight($scope);
  setWidth($scope);
  return $("html, body").animate({
    scrollTop: $("#btn-next").offset().top
  }, 300);
};

setWidth = function($scope) {
  return $(".reading-block").each(function() {
    return $(this).css("width", $scope.settings.width + "px");
  });
};

setFont = function($scope) {
  return setCssProp("font-size", $scope.settings.font_size + "px");
};

setLineHeight = function($scope) {
  return setCssProp("line-height", $scope.settings.line_height + "px");
};

setCssProp = function(name, val) {
  return $(".reading-area p").each(function() {
    return $(this).css(name, val);
  });
};

TimeToString = function(time, brief) {
  var hour, min, sec, text;
  sec = Math.round(time % 60);
  min = Math.round(((time - sec) / 60) % 60);
  hour = Math.round((time - (time % 3600)) / 3600);
  text = "";
  if (sec === 0 && min === 0 && hour === 0) {
    return "-";
  }
  if (hour === 1) {
    text += hour + " hour ";
  }
  if (hour > 1) {
    text += hour + " hours ";
  }
  if (min === 1) {
    text += min + " minute ";
  }
  if (min > 1) {
    text += min + " minutes ";
  }
  if (sec < 2) {
    text += sec + " second";
  }
  if (sec > 1) {
    text += sec + " seconds";
  }
  if (brief) {
    text = "";
    if (hour > 0) {
      text = hour + ":";
    }
    if (min > 0 && min < 10 && hour > 0) {
      text += "0" + min + ":";
    } else if (min === 0 && hour > 0) {
      text += "00:";
    } else if (min === 0 && hour === 0) {
      text = "";
    } else {
      text += min + ":";
    }
    if (sec > 0 && sec < 10 && (hour > 0 || min > 0)) {
      text += "0" + sec;
    } else if (sec === 0 && (hour > 0 || min > 0)) {
      text += "00";
    } else {
      text += sec;
    }
  }
  return text;
};

"use strict";


angular.module("myApp").controller("ReadBookCtrl", function($scope, $http, $routeParams) {
  var timer_message_shown;
  $scope.book = {};
  $scope.settings = {};
  $scope.part = {};
  $scope.prevTime = null;
  $scope.nowTime = null;
  $scope.readingTime = 0;
  $scope.allTime = 0;
  $scope.readWords = 0;
  $scope.playing = false;
  $scope.showNum = false;
  $scope.showOpts = false;
  $scope.showStats = false;
  timer_message_shown = 0;
  $http.get("/api/readBook/" + $routeParams.id).success(function(data) {
    console.log(data);
    $scope.book = data.book;
    $scope.settings = data.settings;
    $scope.part = data.part;
    if (!(data.part != null) || $scope.book.finished) {
      $("#btn-next").hide();
      $("#btn-play").hide();
      $("#text").html("<p>The end</p>");
      setAll($scope);
      console.log("end of text");
    } else {
      $("#text").html("<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>");
      setAll($scope);
    }
    return $("a[rel=tooltip]").tooltip();
  });
  $scope.next = function() {
    if (timer_message_shown < 2) {
      $(".alert").alert();
      $(".alert").removeClass("hidden");
      $(".alert").delay(3000).hide(0);
      timer_message_shown++;
    }
    if ($scope.readingTime !== 0) {
      console.log("save time");
      $scope.part.readingTime = Math.round($scope.readingTime / 1000);
      $http.put("/api/part/" + $scope.part._id, $scope.part).success(function(data) {
        return console.log("saved");
      });
      $scope.readingTime = 0;
      $scope.prevTime = (new Date()).getTime();
    }
    if ($scope.part.readingTime != null) {
      $scope.book.readingTime += $scope.part.readingTime;
    }
    $scope.book.readCount.words += $scope.part.count.words;
    $scope.book.readCount.chars += $scope.part.count.chars;
    $scope.book.readCount.charsWithoutSpaces += $scope.part.count.charsWithoutSpaces;
    $scope.book.complete = Math.round($scope.book.readCount.chars * 10000 / $scope.book.count.chars) / 100;
    $scope.book.lastWordPos = $scope.book.readCount.chars;
    $scope.book.currPartNum++;
    return $http.put("/api/save_book/" + $routeParams.id, $scope.book).success(function(data) {
      console.log("book saved");
      console.log("next");
      console.log(data.part);
      if (data.part == null) {
        $scope.book.finished = true;
        $http.put("/api/book_finished/" + $routeParams.id).success(function(data) {
          return console.log("save finishing book");
        });
        $scope.pause();
        $("#time").text();
        $("#text").html("<p>The end</p>");
        $("#btn-next").hide();
        $("#btn-play").hide();
        setAll($scope);
        return console.log("end of text");
      } else {
        $scope.part = data.part;
        $("#text").html("<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>");
        return setAll($scope);
      }
    });
  };
  $scope.prev = function() {
    if ($scope.book.currPartNum > 0) {
      $scope.book.currPartNum--;
      $http.get("/api/part/" + $routeParams.id + "/" + $scope.book.currPartNum).success(function(data) {
        console.log("get previous part");
        console.log(data);
        $scope.part = data.part;
        if ($scope.part.readingTime != null) {
          $scope.book.readingTime -= $scope.part.readingTime;
        }
        $scope.book.readCount.words -= $scope.part.count.words;
        $scope.book.readCount.chars -= $scope.part.count.chars;
        $scope.book.readCount.charsWithoutSpaces -= $scope.part.count.charsWithoutSpaces;
        $scope.book.complete = Math.round($scope.book.readCount.chars * 100 / $scope.book.count.chars);
        $http.put("/api/save_book/" + $routeParams.id, $scope.book).success(function(data) {
          return console.log("book saved");
        });
        $("#text").html("<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>");
        return setAll($scope);
      });
    }
    return $scope.book.currPartNum === 0;
  };
  $scope.play = function() {
    if (!$scope.playing) {
      $scope.playing = true;
      $scope.prevTime = (new Date()).getTime();
      return $scope.intervalId = setInterval($scope.sec, 1000);
    }
  };
  $scope.pause = function() {
    if ($scope.playing) {
      $scope.playing = false;
      $scope.sec();
      return clearInterval($scope.intervalId);
    }
  };
  $scope.sec = function() {
    $scope.nowTime = (new Date()).getTime();
    $scope.readingTime += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;
    return $("#time").text(TimeToString($scope.readingTime / 1000));
  };
  $scope.font_increase = function() {
    $scope.settings.font_size++;
    return setFont($scope);
  };
  $scope.font_decrease = function() {
    if ($scope.settings.font_size > 0) {
      $scope.settings.font_size--;
      return setFont($scope);
    }
  };
  $scope.line_increase = function() {
    $scope.settings.line_height++;
    return setLineHeight($scope);
  };
  $scope.line_decrease = function() {
    if ($scope.settings.line_height > 0) {
      $scope.settings.line_height--;
      return setLineHeight($scope);
    }
  };
  $scope.width_increase = function() {
    $scope.settings.width += 20;
    return setWidth($scope);
  };
  $scope.width_decrease = function() {
    if ($scope.settings.width > 0) {
      $scope.settings.width -= 20;
      return setWidth($scope);
    }
  };
  $scope.part_increase = function() {
    $scope.settings.part_length += 100;
    return ResetParts($scope, $http);
  };
  $scope.part_decrease = function() {
    if (parseInt($scope.settings.part_length) > 0) {
      $scope.settings.part_length -= 100;
      return ResetParts($scope, $http);
    }
  };
  return $scope.save_settings = function() {
    return saveSettings($scope, $http);
  };
});