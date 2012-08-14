"use strict";

angular.module('myApp').controller('IndexCtrl', function($scope, $http) {
  return $http.get("/api/books").success(function(data, status, headers, config) {
    return $scope.books = data.books;
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
