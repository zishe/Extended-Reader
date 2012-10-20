endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) isnt -1

endsWithArr = (str, suffix) ->
  i = suffix.length - 1
  while i >= 0
    return true  if str.indexOf(suffix[i], str.length - suffix[i].length) isnt -1
    i--

$("a[rel=tooltip]").tooltip()

Mousetrap.bind "space", ->
  console.log "space"
  $("#btn-next").click()

Mousetrap.bind "right", ->
  console.log "right"
  $("#btn-next").click()

Mousetrap.bind "left", ->
  console.log "left"
  $("#btn-prev").click()

$(".dropdown-toggle").dropdown()