endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) isnt -1

endsWithArr = (str, suffix) ->
  i = suffix.length - 1
  while i >= 0
    return true if str.indexOf(suffix[i], str.length - suffix[i].length) isnt -1
    i--

Mousetrap.bind "space", ->
  console.log "space"
  $("#btn-next").click()

Mousetrap.bind "right", ->
  console.log "right"
  $("#btn-next").click()

Mousetrap.bind "left", ->
  console.log "left"
  $("#btn-prev").click()

$("a[rel=tooltip]").tooltip()
$(".dropdown-toggle").dropdown()

$('#fine-uploader').ready ->
  # restricteduploader = new qq.FileUploader(
  #   # If we're using jQuery, there's another way of selecting the DOM node
  #   element: $("#restricted-fine-uploader")[0]
  #   action: "do-nothing.htm"
  #   debug: true
  #   multiple: false
  #   allowedExtensions: ["jpeg", "jpg", "txt"]
  #   sizeLimit: 51200 # 50 kB = 50 * 1024 bytes
  #   uploadButtonText: "Click or Drop"
  #   showMessage: (message) ->

  #     # Using Bootstrap's classes and jQuery selector and DOM manipulation
  #     $("#restricted-fine-uploader").append "<div class=\"alert alert-error\">" + message + "</div>"
  # )

  # uploader = new qq.FileUploader(
  #   element: $("#fine-uploader")
  #   action: "do-nothing.htm"
  # )