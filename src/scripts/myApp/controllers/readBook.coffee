saveSettings = ($scope, $http) ->
  console.log $scope.settings

  $http.put("/api/settings/" + $scope.settings._id, $scope.settings).success (data) ->
    console.log data
    console.log "settings saved"

ResetParts = ($scope, $http) ->
  $http.post("/api/reset_parts/" + $scope.book._id + "/" + $scope.settings.part_length).success (data) ->

setAll = ($scope) ->

  # setBgColor($scope);
  setFont $scope
  setLineHeight $scope
  setWidth $scope
  $("html, body").animate
    scrollTop: $("#btn-next").offset().top
  , 300

# function setBgColor($scope) {
#   $('body').css("background-color", '#E5E8D3');
# };
setWidth = ($scope) ->
  # console.log('set width : ' + $scope.settings.width + 'px');
  $(".reading-block").each ->
    $(this).css "width", $scope.settings.width + "px"

setFont = ($scope) ->
  setCssProp "font-size", $scope.settings.font_size + "px"

setLineHeight = ($scope) ->
  setCssProp "line-height", $scope.settings.line_height + "px"

setCssProp = (name, val) ->
  # console.log('set css: ' + name + " : " + val);
  $(".reading-area p").each ->
    $(this).css name, val

TimeToString = (time, brief) ->
  sec = Math.round(time % 60)
  min = Math.round(((time - sec) / 60) % 60)
  hour = Math.round(((time - (time % 3600)) / 3600))

  text = ""
  return "-"  if sec is 0 and min is 0 and hour is 0
  text += hour + " hour "  if hour is 1
  text += hour + " hours "  if hour > 1
  text += min + " minute "  if min is 1
  text += min + " minutes "  if min > 1
  text += sec + " second"  if sec < 2
  text += sec + " seconds"  if sec > 1
  if brief
    text = ""
    text = hour + ":"  if hour > 0
    if min > 0 and min < 10 and hour > 0 #12:[0]3:33
      text += "0" + min + ":"
    else if min is 0 and hour > 0 #12:[00]:35
      text += "00:"
    else if min is 0 and hour is 0
      text = ""
    else
      text += min + ":"
    if sec > 0 and sec < 10 and (hour > 0 or min > 0) #12:34:[0]2
      text += "0" + sec
    else if sec is 0 and (hour > 0 or min > 0) #12:34:[00]
      text += "00"
    else
      text += sec
  text

"use strict"
angular.module("myApp").controller "ReadBookCtrl", ($scope, $http, $routeParams) ->
  $scope.book = {}
  $scope.settings = {}
  $scope.part = {}

  $scope.prevTime = null
  $scope.nowTime = null
  $scope.readingTime = 0
  $scope.allTime = 0

  $scope.readWords = 0
  $scope.playing = false
  $scope.showNum = false
  $scope.showOpts = false
  $scope.showStats = false
  timer_message_shown = 0

  $http.get("/api/readBook/" + $routeParams.id).success (data) ->
    console.log data
    $scope.book = data.book
    $scope.settings = data.settings
    $scope.part = data.part
    if not data.part? or $scope.book.finished
      $("#btn-next").hide()
      $("#btn-play").hide()
      $("#text").html "<p>The end</p>"
      setAll $scope
      console.log "end of text"
    else
      $("#text").html "<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>"
      setAll $scope
    $("a[rel=tooltip]").tooltip()


  $scope.next = ->
    if timer_message_shown < 2
      $(".alert").alert()
      $(".alert").removeClass "hidden"
      $(".alert").delay(3000).hide 0
      timer_message_shown++
    unless $scope.readingTime is 0
      console.log "save time"
      $scope.part.readingTime = Math.round($scope.readingTime / 1000)
      $http.put("/api/part/" + $scope.part._id, $scope.part).success (data) ->
        console.log "saved"

      $scope.readingTime = 0
      $scope.prevTime = (new Date()).getTime()

    $scope.book.readingTime += $scope.part.readingTime if $scope.part.readingTime?

    $scope.book.readCount.words += $scope.part.count.words
    $scope.book.readCount.chars += $scope.part.count.chars
    $scope.book.readCount.charsWithoutSpaces += $scope.part.count.charsWithoutSpaces
    $scope.book.complete = Math.round($scope.book.readCount.chars * 10000 / $scope.book.count.chars) / 100

    $scope.book.lastWordPos = $scope.book.readCount.chars
    $scope.book.currPartNum++

    $http.put("/api/save_book/" + $routeParams.id, $scope.book).success (data) ->
      console.log "book saved"
      console.log "next"
      console.log data.part
      unless data.part?
        $scope.book.finished = true
        $http.put("/api/book_finished/" + $routeParams.id).success (data) ->
          console.log "save finishing book"

        $scope.pause()
        $("#time").text()
        $("#text").html "<p>The end</p>"
        $("#btn-next").hide()
        $("#btn-play").hide()
        setAll $scope
        console.log "end of text"
      else
        $scope.part = data.part
        $("#text").html "<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>"
        setAll $scope


  $scope.prev = ->
    if $scope.book.currPartNum > 0
      $scope.book.currPartNum--
      $http.get("/api/part/" + $routeParams.id + "/" + $scope.book.currPartNum).success (data) ->
        console.log "get previous part"
        console.log data
        $scope.part = data.part
        $scope.book.readingTime -= $scope.part.readingTime  if $scope.part.readingTime?
        $scope.book.readCount.words -= $scope.part.count.words
        $scope.book.readCount.chars -= $scope.part.count.chars
        $scope.book.readCount.charsWithoutSpaces -= $scope.part.count.charsWithoutSpaces
        $scope.book.complete = Math.round($scope.book.readCount.chars * 100 / $scope.book.count.chars)
        $http.put("/api/save_book/" + $routeParams.id, $scope.book).success (data) ->
          console.log "book saved"

        $("#text").html "<p>" + $scope.part.text.replace(/\n/g, "</p><p>") + "</p>"
        setAll $scope

    $scope.book.currPartNum is 0

  $scope.play = ->
    unless $scope.playing
      $scope.playing = true
      $scope.prevTime = (new Date()).getTime()
      $scope.intervalId = setInterval($scope.sec, 1000)

  $scope.pause = ->
    if $scope.playing
      $scope.playing = false
      $scope.sec()
      clearInterval $scope.intervalId

  $scope.sec = ->
    $scope.nowTime = (new Date()).getTime()
    $scope.readingTime += $scope.nowTime - $scope.prevTime
    $scope.prevTime = $scope.nowTime
    $("#time").text TimeToString($scope.readingTime / 1000)

  $scope.font_increase = ->
    $scope.settings.font_size++
    setFont $scope

  $scope.font_decrease = ->
    if $scope.settings.font_size > 0
      $scope.settings.font_size--
      setFont $scope

  $scope.line_increase = ->
    $scope.settings.line_height++
    setLineHeight $scope

  $scope.line_decrease = ->
    if $scope.settings.line_height > 0
      $scope.settings.line_height--
      setLineHeight $scope

  $scope.width_increase = ->
    $scope.settings.width += 20
    setWidth $scope

  $scope.width_decrease = ->
    if $scope.settings.width > 0
      $scope.settings.width -= 20
      setWidth $scope

  $scope.part_increase = ->
    $scope.settings.part_length += 100
    ResetParts $scope, $http

  $scope.part_decrease = ->
    if parseInt($scope.settings.part_length) > 0
      $scope.settings.part_length -= 100
      ResetParts $scope, $http

  $scope.save_settings = ->
    saveSettings $scope, $http
