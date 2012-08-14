"use strict";

angular.module('myApp').controller('IndexCtrl', function($scope, $http) {
  return $http.get("/api/books").success(function(data, status, headers, config) {
    return $scope.books = data.books;
  });
});

angular.module('myApp').controller('ReadBookCtrl', function($scope, $http, $routeParams) {
  $scope.book = {};
  $scope.content = {};
  $http.get("/api/book/" + $routeParams.id).success(function(data) {
    var t = $(data.book.text);
    // $scope.content = t.find('body').text();
    var xmlDoc = $.parseXML( data.book.text );
    console.log(xmlDoc);
    var $xml = $( xmlDoc );
    var body = $($xml.find("body"));
    $('#text').xslt(body, 'FB2_2_xhtml.xsl');

    // $('#text').html(html);

    return $scope.book = data.book;
  });
});

angular.module('myApp').controller('AddBookCtrl', function($scope, $http, $location) {
  $scope.open = function() {
    $http.defaults.headers = {'Content-Type':'multipart/form-data'};
    return $http.post('/uploadfile', $scope.form).success(function(data) {
      // return $scope.post = data.post;
      uploaded = data.book;
      $('#status').html(data.book);
    });
  };

    // // $http.defaults.headers = {'Content-Type':'multipart/form-data'};
    // return $http({method: 'POST', url: '/uploadfile', headers: {'Content-Type':'multipart/form-data; boundary=' + Math.floor((Math.random()*10000)+1) + '; charset=UTF-8'}, data: $scope.form}).success(function(data) {
    //   // return $scope.post = data.post;
    //   uploaded = data.book;
    //   // $('#status').html(data.book);
    // }).error(function(data, status) {
    //     $scope.data = data || "Request failed";
    //     $scope.status = status;
    // });;

});
