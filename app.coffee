express = require 'express'
http = require 'http'
path = require 'path'
mongoose = require 'mongoose'
passport = require 'passport'

routes = require './controllers'
api = require './controllers/api'
auth = require './modules/auth-init'
auth_routes = require './routes/auth-routes'
api_routes = require './routes/api-routes'

auth passport


db = null
app = express()

# require('nodetime').profile ->
#   accountKey: '92798cace79d721d196c3697e51c1758c40a5147'
#   appName: 'Node.js Application'


# require('look').start();

app.configure ->
  app.set 'port', process.env.PORT or 4000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser(
      keepExtensions: true
      uploadDir: __dirname + '/upload/files'
    )
  app.use express.limit('5mb')
  app.use express.methodOverride()
  app.use express.cookieParser('gfjfkghds9g7fds')
  app.use express.session()
  app.use passport.initialize()
  app.use passport.session()
  app.use express.static(path.join(__dirname, 'staging'))
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )
  db = mongoose.connect 'mongodb://user:user@ds037007.mongolab.com:37007/speed-reading'
  # db = mongoose.connect 'mongodb://alder:alder@linus.mongohq.com:10078/reader'
  # db = mongoose.connect 'mongodb://localhost/speed-reading'

# Routes
app.get '/', routes.index
app.get '/partials/:name', routes.partials

api_routes app, api
auth_routes app, passport

# redirect all others to the index (HTML5 history)
app.get '*',  (req, res) ->
  res.render "index"

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
