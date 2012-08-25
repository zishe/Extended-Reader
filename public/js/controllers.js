"use strict";


//  Index
angular.module('myApp').controller('IndexCtrl', function($scope, $http) {
  return $http.get("/api/books").success(function(data, status, headers, config) {
    return $scope.books = data.books;
  });
});



// Add Book
angular.module('myApp').controller('AddBookCtrl', function($scope, $http, $location) {
  $scope.book = {};
  $scope.save = function() {
    return $http.post("/api/book", $scope.book).success(function(data) {
      return $location.path("/");
    });
  };

  return $scope.cancel = function() {
    return $location.path("/");
  };
});


// Edit Book
angular.module('myApp').controller('EditBookCtrl', function($scope, $http, $location, $routeParams) {
  $scope.book = {};
  $http.get("/api/bookwithtext/" + $routeParams.id).success(function(data) {
    return $scope.book = data.book;
  });
  $scope.save = function() {
    return $http.put("/api/book/" + $routeParams.id, $scope.book).success(function(data) {
      return $location.url("/readBook/" + $routeParams.id);
    });
  };
  return $scope.cancel = function() {
    return $location.path("/");
  };
});


// Delete Book
angular.module('myApp').controller('DeleteBookCtrl', function($scope, $http, $location, $routeParams) {
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    return $scope.book = data.book;
  });
  $scope.delete = function() {
    $http["delete"]('/api/book/' + $routeParams.id).success(function(data) {
      $location.url("/");
    });
  };
  return $scope.cancel = function() {
    return $location.path("/");
  };
});






// View Book
angular.module('myApp').controller('ViewBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.readingTime = 0;
  $scope.readWords = 0;
  
  return $http.get("/api/book/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.book.complete = Math.round($scope.book.parts[$scope.book.partNum].startPos * 100 / $scope.book.count.chars);
    
    angular.forEach($scope.book.parts, function(part, num){
      if (part.readingTime != null)
        $scope.readingTime += part.readingTime;
    });
    $scope.book.readingTime = TimeToString($scope.readingTime);

    var i = 1;
    angular.forEach($scope.book.parts, function(part, num){
      if (i < $scope.book.partNum) {
          $scope.readWords += part.countWords;
          i++;
        }
    });
    $scope.book.readWords = $scope.readWords;
    //var sampleDate = new Date($scope.book.created);
    //sampleDate.format('dd mmm yyyy');
    $scope.book.createdDate = $.format.date($scope.book.created, "dd MMMM yyyy");

    getGraph($scope);
    return $scope.book;
  });
});


function getGraph($scope) {
  var num = 0;
  var fl = true;
  var decimal_data = [];
  while (fl){
    var part = $scope.book.parts[num];
    if (part.readingTime == null)
      fl = false;
    else
    {
      decimal_data.push({
        x: num,
        y: Math.round(part.countWords / part.readingTime * 60)
      });
    }
    num++;
  }
  console.log(decimal_data);

  Morris.Line({
    element: 'graph',
    data: decimal_data,
    xkey: 'x',
    ykeys: ['y'],
    labels: ['Speed'],
    parseTime: false,
    hideHover: true
    
  });
};



// Read Book
angular.module('myApp').controller('ReadBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.settings = {};

  $scope.prevTime = null;
  $scope.nowTime = null;
  $scope.readingTime = 0;
  $scope.playing = false;

  
  $http.get("/api/readBook/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.settings = data.settings;
    setPart($scope);
    setAll($scope);
    setGraph($scope);
    if (($scope.book.parts.length < ($scope.book.partNum + 5)) && !$scope.book.endRead) {
      $http.put("/api/addparts/" + $routeParams.id).success(function(data) {
        console.log('loaded new book data');
        $scope.book = data.book;
        
      });
    }
  });

  $scope.next = function() {
    if ($scope.readingTime != 0) {
      console.log('update time');
      $scope.book.parts[$scope.book.partNum].readingTime = Math.round($scope.readingTime / 1000);
      $http.put("/api/settime/" + $routeParams.id + '/' + $scope.book.partNum, {time: Math.round($scope.readingTime / 1000)}).success(function(data) {
        
      });
      $scope.readingTime = 0;
      $scope.prevTime = (new Date()).getTime();
    }

    $scope.book.partNum = $scope.book.partNum + 1;

    if ($scope.book.parts.length > $scope.book.partNum) {
      console.log('next');
      setPart($scope);
      setAll($scope);
      
      $http.put("/api/setnum/" + $routeParams.id + '/' + $scope.book.partNum).success(function(data) {
        console.log('save part num');
        if ($scope.book.parts.length < ($scope.book.partNum + 5) && !$scope.book.endRead) {
          $http.put("/api/addparts/" + $routeParams.id).success(function(data) {
            console.log('loaded new book data');
            $scope.book = data.book;
          });
        }
      });
    }
    else{
      $('#text').html("<p>The end</p>");
      setAll($scope);
      console.log('end of text');
    }
  };

  $scope.showGraph = function() {
    $('.graph-block').show(500);
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

  $scope.font_increase = function() {
    $scope.settings.font_size = parseInt($scope.settings.font_size) + 1;
    saveSettings($scope, $http);
    setFont($scope);
  };

  $scope.sec = function() {
    $scope.nowTime = (new Date()).getTime();
    $scope.readingTime += $scope.nowTime - $scope.prevTime;
    $scope.prevTime = $scope.nowTime;

    // console.log($scope.prevTime);
    // console.log($scope.readingTime);

    $('#time').text(TimeToString($scope.readingTime));
  }

  $scope.font_decrease = function() {
    if (parseInt($scope.settings.font_size) > 0) {
      $scope.settings.font_size = parseInt($scope.settings.font_size) - 1;
      saveSettings($scope, $http);
      setFont($scope);
    }
  };


  $scope.line_increase = function() {
    $scope.settings.line_height = parseInt($scope.settings.line_height) + 1;
    saveSettings($scope, $http);
    setLineHeight($scope);
  };

  $scope.line_decrease = function() {
    if (parseInt($scope.settings.line_height) > 0) {
      $scope.settings.line_height = parseInt($scope.settings.line_height) - 1;
      saveSettings($scope, $http);
      setLineHeight($scope);
    }
  };


  $scope.width_increase = function() {
    $scope.settings.width = parseInt($scope.settings.width) + 20;
    saveSettings($scope, $http);
    setWidth($scope);
  };

  $scope.width_decrease = function() {
    if (parseInt($scope.settings.width) > 0) {
      $scope.settings.width = parseInt($scope.settings.width) - 20;
      saveSettings($scope, $http);
      setWidth($scope);
    }
  };


  $scope.part_increase = function() {
    $scope.settings.part_length = parseInt($scope.settings.part_length) + 100;
    saveSettings($scope, $http);
    setPartLength($scope, $http);
  };

  $scope.part_decrease = function() {
    if (parseInt($scope.settings.part_length) > 0) {
      $scope.settings.part_length = parseInt($scope.settings.part_length) - 100;
      saveSettings($scope, $http);
      setPartLength($scope, $http);
    }
  };
});



function setCssProp($scope, prop_name, prop_val) {
  // console.log('set css: ' + prop_name + " : " + prop_val);
  $('.reading-area p').each(function() {
    $(this).css(prop_name, prop_val);
  });
};


function saveSettings($scope, $http) {
  $http.post("/api/save_settings/" + $scope.settings._id, $scope.settings).success(function(data) {
  });
};

function setPartLength($scope, $http) {
  $http.post("/api/save_settings/" + $scope.settings._id, $scope.settings).success(function(data) {
  });
};

function setAll($scope) {
  setFont($scope);
  setLineHeight($scope);
  setWidth($scope);
  $('html, body').animate({
    scrollTop: $('#btn-next').offset().top
    }, 300
  );
  $('#btn-next').tipsy({gravity: 'n'});
  $('#btn-play').tipsy({gravity: 'n'});
};


function setFont($scope) {
  setCssProp($scope, "font-size", $scope.settings.font_size + 'px');
};

function setLineHeight($scope) {
  setCssProp($scope, "line-height", $scope.settings.line_height + 'px');
};

function setWidth($scope) {
  // console.log('set width : ' + $scope.settings.width + 'px');
  $('.reading-block').each(function() {
    $(this).css("width", $scope.settings.width + 'px');
  });
};

function setPart($scope) {
  $scope.book.currPart = $scope.book.parts[$scope.book.partNum]
  $scope.content = '<p>' + $scope.book.currPart.text.replace(/\n/g, '</p><p>') + '</p>';
  $('#text').html($scope.content);
};




function setGraph($scope) {
  var num = 0;
  var fl = true;
  var text = '';
  console.log('fdsafdsafsda');
  while (fl){
    var part = $scope.book.parts[num];
    if (part.readingTime == null)
      fl = false;
    else
    {
      text += num + ',' + (part.countWords / part.readingTime * 60) + '\n';
    }
    num++;
  }
  console.log(text);

  var g = new Dygraph(
    document.getElementById("graphdiv"),
    "Part,Words in minute\n" + text,
    {
      // // fractions: true,
      // errorBars: true,
      width: 800
    }
  );
};

function TimeToString(time) {
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

  if (sec == 1)
    text = text + sec + ' second ';
  if (sec > 1)
    text = text + sec + ' seconds ';
  return text;
};