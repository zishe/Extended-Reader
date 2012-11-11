"use strict";

angular.module("myApp").controller("FileUploadCtrl", function($scope, $http, $location) {
  var uploadCanceled, uploadComplete, uploadFailed, uploadProgress;
  $scope.setFiles = function(element) {
    return $scope.$apply(function($scope) {
      var i;
      console.log("files:", element.files);
      $scope.files = [];
      i = 0;
      while (i < element.files.length) {
        $scope.files.push(element.files[i]);
        i++;
      }
      return $scope.progressVisible = false;
    });
  };
  $scope.uploadFile = function() {
    var fd, i, xhr;
    fd = new FormData();
    for (i in $scope.files) {
      fd.append("uploadedFile", $scope.files[i]);
    }
    xhr = new XMLHttpRequest();
    xhr.upload.addEventListener("progress", uploadProgress, false);
    xhr.open("POST", "/api/uploadfile");
    $scope.progressVisible = true;
    return xhr.send(fd);
  };
  uploadProgress = function(evt) {
    return $scope.$apply(function() {
      if (evt.lengthComputable) {
        return $scope.progress = Math.round(evt.loaded * 100 / evt.total);
      } else {
        return $scope.progress = "unable to compute";
      }
    });
  };
  uploadComplete = function(evt) {
    return alert(evt.target.responseText);
  };
  uploadFailed = function(evt) {
    return alert("There was an error attempting to upload the file.");
  };
  return uploadCanceled = function(evt) {
    $scope.$apply(function() {
      return $scope.progressVisible = false;
    });
    return alert("The upload has been canceled by the user or the browser dropped the connection.");
  };
});
