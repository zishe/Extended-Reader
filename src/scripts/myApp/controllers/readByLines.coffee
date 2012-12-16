"use strict"
angular.module("myApp").controller "ReadByLinesCtrl", ($scope, $http, $routeParams, $timeout) ->
  $scope.book = {}
  $scope.settings = {}
  $scope.showOpts = false
  $scope.playing = false
  $scope.parts = []
  $scope.curr = ""
  $scope.currText = ""
  $scope.num = 0
  $scope.readText = ""
  $scope.prevTime = null
  $scope.nowTime = null
  $scope.reading_time = 0
  timeout = undefined

  $http.get("/api/book_with_text/" + $routeParams.id).success (data) ->
    $scope.book = data.book
    $scope.text = data.book.text

    if $scope.book.last_word_pos > 0
      $scope.text = $scope.book.text.substr($scope.book.last_word_pos, $scope.book.text.length - 1)
    else $scope.book.last_word_pos = 0  unless $scope.book.last_word_pos is 0
    $scope.book.text = null

    console.log "open book"
    $("#time").text()
    $http.get("/api/settings").success (data) ->
      $scope.settings = data.settings
      console.log data.settings

      setWordsFont $scope
      changed = false
      unless $scope.settings.words_font_size?
        $scope.settings.words_font_size = 20
        changed = true
      unless $scope.settings.words_count?
        $scope.settings.words_count = 3
        changed = true
      if $scope.settings.words_delay < 100
        $scope.settings.words_delay = 300
        changed = true
      saveSettings $scope, $http  if changed
      collect_parts $scope

  $scope.play = ->
    unless $scope.playing
      $scope.prevTime = (new Date()).getTime()
      $scope.playing = true
      tick()


  $scope.pause = ->
    if $scope.playing
      $scope.playing = false
      $timeout.cancel timeout

      count = getWordsCount($scope.readText)
      $scope.book.reading_time += Math.round($scope.reading_time / 1000)
      $scope.book.read_count.words += count.words
      $scope.book.read_count.chars += count.chars
      $scope.book.read_count.symbols += count.symbols
      $scope.book.complete = Math.round($scope.book.read_count.chars * 100 / $scope.book.count.chars)

      $scope.book.last_word_pos = 0  unless $scope.book.last_word_pos?
      $scope.book.last_word_pos += $scope.readText.length
      $http.put("/api/save_stats/" + $routeParams.id, $scope.book).success (data) ->
        console.log "stats saved"

      $scope.readText = ""
      $scope.reading_time = 0

  tick = ->
    $scope.readText += $scope.currText + " "  if $scope.num > 0

    # $scope
    $scope.currText = $scope.parts[$scope.num]
    $scope.num++
    $scope.nowTime = (new Date()).getTime()
    $scope.reading_time += $scope.nowTime - $scope.prevTime
    $scope.prevTime = $scope.nowTime
    $("#time").text TimeToString($scope.reading_time / 1000)
    showing_time = ($scope.currText.length / ($scope.settings.words_speed * 7 / 60)) * 1000
    # console.log showing_time
    timeout = $timeout(tick, showing_time)
    # extra_lngth = $scope.currText.length - $scope.settings.words_count * 7
    # extra_time = (if extra_lngth > 0 then Math.round(extra_lngth / 5) else 0)
    # console.log extra_time
    # timeout = $timeout(tick, $scope.settings.words_delay + extra_time*100)

  $scope.change_text = ->
    $("#text").text $scope.parts[$scope.num]
    $scope.num++

  $scope.font_increase = ->
    $scope.settings.words_font_size++
    setWordsFont $scope

  $scope.font_decrease = ->
    if $scope.settings.words_font_size > 1
      $scope.settings.words_font_size--
      setWordsFont $scope

  $scope.words_increase = ->
    $scope.settings.words_count++
    reset_parts $scope

  $scope.words_decrease = ->
    if $scope.settings.words_count > 1
      $scope.settings.words_count--
      reset_parts $scope

  $scope.length_increase = ->
    $scope.settings.words_length++
    reset_parts $scope

  $scope.length_decrease = ->
    if $scope.settings.words_length > 1
      $scope.settings.words_length--
      reset_parts $scope

  $scope.dalay_increase = ->
    $scope.settings.words_delay += 30

  $scope.dalay_decrease = ->
    $scope.settings.words_delay -= 30 if $scope.settings.words_delay > 50

  $scope.speed_increase = ->
    $scope.settings.words_speed += 5

  $scope.speed_decrease = ->
    $scope.settings.words_speed -= 5 if $scope.settings.words_speed > 50

  $scope.save_settings = ->
    saveSettings $scope, $http

  setWordsFont = ->
    $("#text").css "font-size", $scope.settings.words_font_size + "px"
    $("#text").css "line-height", ($scope.settings.words_font_size + 10) + "px"

  reset_parts = ->
    $scope.parts = []
    collect_parts $scope

  collect_parts = ->
    angular.forEach $scope.text.replace(/[\s\n\t\r]+/g, " ").split(" "), (word, num) ->
      $scope.curr += " " + word
      # m = $scope.curr.match(/\S+/g)
      # if m and (m.length >= $scope.settings.words_count or endsWithArr($scope.curr, [".", ";"]))
      if $scope.curr.length >= $scope.settings.words_length or endsWithArr($scope.curr, [".", ";", "...", "...", "?", "!"])
        $scope.parts.push $scope.curr.trim()
        $scope.curr = ""


getWordsCount = (text) ->
  console.log "Define words and chars count"
  count = {}
  count.chars = text.length
  count.symbols = text.replace(/\s+/g, "").length
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, "").replace(/\s+/g, " ").trim().split(" ").length
  console.log "chars: " + count.chars
  console.log "chars wothout spaces: " + count.symbols
  console.log "words count: " + count.words
  count
