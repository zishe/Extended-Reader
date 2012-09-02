express = require 'express'
http = require 'http'
path = require 'path'

assets = require 'connect-assets'

routes = require './routes'
api = require './routes/api'
mongoose = require 'mongoose'



# https://github.com/jaredhanson/passport-google-oauth/blob/master/examples/oauth2/app.js

passport = require 'passport'
util = require 'util'
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

# API Access link for creating client ID and secret:
# https://code.google.com/apis/console/
GOOGLE_CLIENT_ID = "236823754682-c22gabjasrta49kj9cnjcqo0cmmfppov.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET = "egJtIvQgODZzTR4NubcJ2qgr"

# Passport session setup.
#   To support persistent login sessions, Passport needs to be able to
#   serialize users into and deserialize users out of the session.  Typically,
#   this will be as simple as storing the user ID when serializing, and finding
#   the user by ID when deserializing.  However, since this example does not
#   have a database of user records, the complete Google profile is
#   serialized and deserialized.
passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

# Use the GoogleStrategy within Passport.
#   Strategies in Passport require a `verify` function, which accept
#   credentials (in this case, an accessToken, refreshToken, and Google
#   profile), and invoke a callback with a user object.
passport.use new GoogleStrategy(
  clientID: GOOGLE_CLIENT_ID
  clientSecret: GOOGLE_CLIENT_SECRET
  callbackURL: "http://localhost:4000/oauth2callback"
, (accessToken, refreshToken, profile, done) ->
    # asynchronous verification, for effect...
  process.nextTick ->
      
      # To keep the example simple, the user's Google profile is returned to
      # represent the logged-in user.  In a typical application, you would want
      # to associate the Google account with a user record in your database,
      # and return that user instead.
      # return done(null, profile);
)









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
  app.use passport.initialize()
  app.use passport.session()
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

app.put '/api/save_book/:id', api.saveBook
app.put '/api/book_finished/:id', api.finishBook

# app.put '/api/addparts/:id', api.addParts
app.get '/api/book_with_text/:id', api.bookWithText
app.put '/api/reset_parts/:id/:plen', api.resetParts


app.get '/api/book_parts/:id', api.bookParts
app.get '/api/book_part/:id/:num', api.getBookPart
app.put '/api/part/:id', api.savePartTime


app.get '/api/settings', api.settings
app.post '/api/settings/:id', api.saveSettings




# app.get "/oauth2callback", passport.authenticate("google", failureRedirect: "/login"), (req, res) ->
#   res.json user:req.user

app.get "/auth/google", passport.authenticate('google', { scope: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'] }), (req, res) ->

app.get "/oauth2callback", passport.authenticate("google", {failureRedirect: "/login"}), (req, res) ->
  res.redirect "/"


app.get "/login", (req, res) ->
  res.render "index",
    user: req.user

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

# redirect all others to the index (HTML5 history)
# app.get '*',  (req, res) ->
#   res.render "index"


http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')

# Simple route middleware to ensure user is authenticated.
#   Use this route middleware on any resource that needs to be protected.  If
#   the request is authenticated (typically via a persistent login session),
#   the request will proceed.  Otherwise, the user will be redirected to the
#   login page.
ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect "/login"

