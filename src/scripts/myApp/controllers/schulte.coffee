"use strict"

# Add Book
angular.module("myApp").controller "SchulteCtrl", ($scope, $http, $location, $timeout) ->
  $scope.size = 4
  $scope.all = 16
  $scope.arr = []
  $scope.num = 1
  $scope.playing = false
  
  # $scope.start = null;
  timeout = undefined
  odd = false
  $scope.init = ->
    init_arr $scope

  init_arr = ($scope) ->
    arr = []
    count = Math.pow($scope.size, 2)
    if $scope.size % 2 is 1
      odd = true
      count--
      console.log "even " + count
    pre_arr = []
    i = count

    while i > 0
      pre_arr.push i
      i--
    pre_arr.shuffle()
    console.log pre_arr
    i = count - 1

    while i >= 0
      unless odd
        arr.push pre_arr[i]
      else
        if count / 2 is i
          arr.push pre_arr[i]
          arr.push ""
        else
          console.log "even"
          arr.push pre_arr[i]
      i--
    $scope.all = count
    $scope.arr = arr
    console.log arr

  $scope.set_size = ->
    $scope.size = 5
    $(".play-field").removeClass("play-field").addClass "play-field-5"
    $scope.init()

  $scope.start = ->
    init_arr $scope
    $scope.play()

  $scope.turn = (n) ->
    console.log "turn"
    p = $("#" + n).text()
    console.log p
    if p is $scope.num
      if $scope.num is $scope.all
        $(".cicle").css "background-color", "green"
        $scope.num = 1
        $scope.playing = false
        $timeout.cancel timeout
      else
        $scope.num++
        $(".currNum").text $scope.num

  $scope.play = ->
    unless $scope.playing
      $scope.start = (new Date()).getTime()
      $scope.playing = true
      console.log "playing"
      tick()

  tick = ->
    $scope.time = (new Date()).getTime() - $scope.start
    $("#time").text ($scope.time / 1000).toFixed(1)
    timeout = $timeout(tick, 100)

Array::shuffle = (b) ->
  i = @length
  j = undefined
  t = undefined
  while i
    j = Math.floor((i--) * Math.random())
    t = (if b and typeof this[i].shuffle isnt "undefined" then this[i].shuffle() else this[i])
    this[i] = this[j]
    this[j] = t
  this