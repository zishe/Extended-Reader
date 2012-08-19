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









// Read Book
angular.module('myApp').controller('ReadBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.settings = {};
  
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    $scope.book = data.book;
    $scope.settings = data.settings;
    
    $scope.content = '<p>' + $scope.book.currPart.replace(/\n/g, '</p><p>') + '</p>';
    $('#text').html($scope.content);

    setAll($scope);
  });

  $scope.next = function() {
    if ($scope.book.nextParts.length > 0) {
      if (!$scope.book.prevParts || typeof $scope.book.prevParts === undefined){
        console.log('undefined');
        $scope.book.prevParts = new Array();
      }
      $scope.book.prevParts.push($scope.book.currPart);
      $scope.book.currPart = $scope.book.nextParts.shift()
      $scope.content = '<p>' + $scope.book.currPart.replace(/\n/g, '</p><p>') + '</p>';
      $('#text').html($scope.content);
        
      setAll($scope);
    }
    else{
      $('#text').html("<p>The end</p>");
      setAll($scope);
      console.log('end of text');
    }
  };

  $scope.prev = function() {
    if ($scope.book.prevParts.length > 0) {
      $scope.book.nextParts.push($scope.book.currPart);
      $scope.book.currPart = $scope.book.prevParts.pop()
      $scope.content = '<p>' + $scope.book.currPart.replace(/\n/g, '</p><p>') + '</p>';
      $('#text').html($scope.content);
        
      setAll($scope);
    }
  };

  $scope.font_increase = function() {
    $scope.settings.font_size = parseInt($scope.settings.font_size) + 1;
    saveSettings($scope, $http);
    setFont($scope);
  };

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
});

function setCssProp($scope, prop_name, prop_val) {
  console.log('set css: ' + prop_name + " : " + prop_val);
  $('.reading-area p').each(function() {
    $(this).css(prop_name, prop_val);
  });
};


function saveSettings($scope, $http) {
  $http.post("/api/save_settings/" + $scope.settings._id, $scope.settings).success(function(data) {
  });
};

function setAll($scope) {
  setFont($scope);
  setLineHeight($scope);
  setWidth($scope);
  $('html, body').animate({
    scrollTop: $('#btn-next').offset().top// - 48
    }, 200
  );
  $('#btn-next').tipsy({gravity: 'n'});
};


function setFont($scope) {
  setCssProp($scope, "font-size", $scope.settings.font_size + 'px');
};

function setLineHeight($scope) {
  setCssProp($scope, "line-height", $scope.settings.line_height + 'px');
};

function setWidth($scope) {
  console.log('set width : ' + $scope.settings.width + 'px');
  $('.reading-block').each(function() {
    $(this).css("width", $scope.settings.width + 'px');
  });
};
