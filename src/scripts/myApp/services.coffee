"use strict"

angular.module("myApp.services", []).value "version", "0.1"

# angular.module("dbServices", ["ngResource"]).factory "Book", ($resource) ->
#   $resource "/api/books", {},
#     query:
#       method: "GET"
#       # params: { id: "" }
#       isArray: true



# # "upload-app.services"
# angular.module("myApp.services", []).directive("fileButton", ->
#   link: (scope, element, attributes) ->
#     el = angular.element(element)
#     button = el.children()[0]
#     el.css
#       position: "relative"
#       overflow: "hidden"
#       width: button.offsetWidth
#       height: button.offsetHeight

#     fileInput = angular.element("<input id=\"uploadInput\" type=\"file\" multiple />")
#     fileInput.css
#       position: "absolute"
#       top: 0
#       left: 0
#       "z-index": "2"
#       width: "100%"
#       height: "100%"
#       opacity: "0"
#       cursor: "pointer"

#     el.append fileInput
# ).run()
