"use strict"

# Add Book
angular.module("myApp").controller "SchulteCtrl", ($scope, $http, $location, $timeout) ->
  $scope.size = 5
  $scope.all = 25
  $scope.arr = []
  $scope.num = 1
  $scope.playing = false
  timeout = undefined
  odd = false

  $scope.init = ->
    init_arr $scope

  init_arr = ($scope) ->
    arr = []
    count = Math.pow($scope.size, 2)
    odd = $scope.size % 2 is 1
    count-- if odd

    i = count
    while i > 0
      arr.push i
      i--
    arr.shuffle()
    console.log arr

    arr.insert count / 2, "" if odd

    $scope.all = count
    $scope.arr = arr

  $scope.set_size = (n) ->
    $scope.size = n
    $(".play-field").removeClass("play-field-4").removeClass("play-field-5").removeClass("play-field-6")
    if n == 4
      $(".play-field").addClass "play-field-4"
    if n == 5
      $(".play-field").addClass "play-field-5"
    if n == 6
      $(".play-field").addClass "play-field-6"
    $scope.init()

  $scope.start = ->
    init_arr $scope
    $('.start').text('Restart')
    $scope.play()

  $scope.cancel = ->
    $scope.refresh()
    $('.start').text('Start')

  $scope.turn = (n) ->
    p = $("#" + n).text()
    if (p - $scope.num == 0)
      console.log 'right num!'
      if $scope.num == $scope.all
        $scope.refresh()
      else
        $scope.num++
        console.log $scope.num
        $(".currNum").text $scope.num

  $scope.play = ->
    console.log $scope.playing
    unless $scope.playing
      $scope.startTime = (new Date()).getTime()
      $scope.playing = true
      console.log "playing"
      tick()

  $scope.refresh = () ->
    $(".cicle").css "background-color", "green"
    $scope.num = 1
    $scope.playing = false
    $timeout.cancel timeout

  tick = ->
    $scope.time = (new Date()).getTime() - $scope.startTime
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

Array::insert = (index, item) ->
  @splice index, 0, item