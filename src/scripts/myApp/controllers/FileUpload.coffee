"use strict"

# Add Book
angular.module("myApp").controller "FileUploadCtrl", ($scope, $http, $location) ->
  # dropbox = document.getElementById("dropbox")
  # $scope.dropText = "Drop files here..."

  #================ init event handlers =================
  # dragEnterLeave = (evt) ->
  #   evt.stopPropagation()
  #   evt.preventDefault()
  #   $scope.$apply ->
  #     $scope.dropText = "Drop files here..."
  #     $scope.dropClass = ""

  # dropbox.addEventListener "dragenter", dragEnterLeave, false
  # dropbox.addEventListener "dragleave", dragEnterLeave, false
  # dropbox.addEventListener "dragover", ((evt) ->
  #   evt.stopPropagation()
  #   evt.preventDefault()
  #   clazz = "not-available"
  #   ok = evt.dataTransfer and evt.dataTransfer.types and evt.dataTransfer.types.indexOf("Files") >= 0
  #   $scope.$apply ->
  #     $scope.dropText = (if ok then "Drop files here..." else "Only files are allowed!")
  #     $scope.dropClass = (if ok then "over" else "not-available")

  # ), false
  # dropbox.addEventListener "drop", ((evt) ->
  #   console.log "drop evt:", JSON.parse(JSON.stringify(evt.dataTransfer))
  #   evt.stopPropagation()
  #   evt.preventDefault()
  #   $scope.$apply ->
  #     $scope.dropText = "Drop files here..."
  #     $scope.dropClass = ""

  #   files = evt.dataTransfer.files
  #   if files.length > 0
  #     $scope.$apply ->
  #       $scope.files = []
  #       i = 0

  #       while i < files.length
  #         $scope.files.push files[i]
  #         i++

  # ), false


  #============== DRAG & DROP =============

  $scope.setFiles = (element) ->
    $scope.$apply ($scope) ->
      console.log "files:", element.files
      # Turn the FileList object into an Array
      $scope.files = []
      i = 0

      while i < element.files.length
        $scope.files.push element.files[i]
        i++
      $scope.progressVisible = false

  $scope.uploadFile = ->
    fd = new FormData()
    for i of $scope.files
      fd.append "uploadedFile", $scope.files[i]

    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener "progress", uploadProgress, false
    # xhr.addEventListener "load", uploadComplete, false
    # xhr.addEventListener "error", uploadFailed, false
    # xhr.addEventListener "abort", uploadCanceled, false

    xhr.open "POST", "/api/uploadfile"
    $scope.progressVisible = true
    xhr.send fd

  uploadProgress = (evt) ->
    $scope.$apply ->
      if evt.lengthComputable
        $scope.progress = Math.round(evt.loaded * 100 / evt.total)
      else
        $scope.progress = "unable to compute"

  uploadComplete = (evt) ->
    # This event is raised when the server send back a response
    alert evt.target.responseText

  uploadFailed = (evt) ->
    alert "There was an error attempting to upload the file."

  uploadCanceled = (evt) ->
    $scope.$apply ->
      $scope.progressVisible = false

    alert "The upload has been canceled by the user or the browser dropped the connection."

