express = require 'express'
http = require 'http'
path = require 'path'

assets = require 'connect-assets'

routes = require './routes'
api = require './routes/api'
mongoose = require 'mongoose'

db = null
app = express()

# require('nodetime').profile ->
#   accountKey: '92798cace79d721d196c3697e51c1758c40a5147'
#   appName: 'Node.js Application'



app.use assets()

app.configure ->
  app.set 'port', process.env.PORT or 4000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser(
      keepExtensions: true
      uploadDir: __dirname + '/public/files'
    )
  app.use express.limit('5mb')
  app.use express.methodOverride()
  app.use express.cookieParser('gfjfkghds9g7fds')
  app.use express.session()
  # app.use require('stylus').middleware(__dirname + '/public')
  app.use require('less-middleware')(src: __dirname + '/public')
  app.use express.static(path.join(__dirname, 'public'))
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  # db = mongoose.connect 'mongodb://user:user@ds037007.mongolab.com:37007/speed-reading'
  db = mongoose.connect 'mongodb://localhost/speed-reading'

app.configure "production", ->
  app.use express.errorHandler()
  db = mongoose.connect 'mongodb://user:user@ds037007.mongolab.com:37007/speed-reading'


 # Routes
app.get '/', routes.index
app.get '/partials/:name', routes.partials

# JSON API
app.get '/api/books', api.books
app.get '/api/book/:id', api.book
app.post '/api/book', api.addBook
app.put '/api/book/:id', api.editBook
app.delete '/api/book/:id', api.deleteBook

app.get '/api/readBook/:id', api.readBook
app.get '/api/readByLines/:id', api.readByLines

app.put '/api/part/:id', api.savePartTime
# app.put '/api/reset_parts/:id/:pid', api.resetParts

# app.put '/api/addparts/:id', api.addParts
app.get '/api/book_with_text/:id', api.bookWithText

app.get '/api/book_parts/:id', api.bookParts
app.put '/api/save_book/:id', api.saveBook
app.put '/api/book_finished/:id', api.finishBook


app.get '/api/settings', api.settings
app.post '/api/settings/:id', api.saveSettings

# redirect all others to the index (HTML5 history)
app.get '*',  (req, res) ->
  res.render "index"

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
