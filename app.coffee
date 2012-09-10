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
GitHubStrategy = require('passport-github').Strategy
TwitterStrategy = require('passport-twitter').Strategy
VKontakteStrategy = require('passport-vkontakte').Strategy
FacebookStrategy = require('passport-facebook').Strategy


# Google
GOOGLE_CLIENT_ID = "236823754682.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET = "G4OHfDVVDg4Cv2qUuC9oYdfK"

# GitHub
GITHUB_CLIENT_ID = "79021490aa56a31ffbc7"
GITHUB_CLIENT_SECRET = "2cb82b73453eb054945893f615b4afc7ca828be3"

# Twitter
TWITTER_CONSUMER_KEY = "k6a3LMZJMP3Jzptt2KiQ"
TWITTER_CONSUMER_SECRET = "GbQfsouBoLillhhVYiYLJfQUDNMnhyKQu55zvk7hg"

# Vk
VKONTAKTE_APP_ID = "3108473"
VKONTAKTE_APP_SECRET = "OJm81O8ieCMV2E5KCgYH"

# Fb
FACEBOOK_APP_ID = "380589482013093"
FACEBOOK_APP_SECRET = "c95206a965a3fb1775ff16f4337e0dc0"







# Serializers

passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj


# Stratagies

passport.use new GoogleStrategy(
  clientID: GOOGLE_CLIENT_ID
  clientSecret: GOOGLE_CLIENT_SECRET
  callbackURL: "http://extended-reader.herokuapp.com/oauth2callback" # localhost:3000
, (accessToken, refreshToken, profile, done) ->
  
  # asynchronous verification, for effect...
  process.nextTick ->
    done null, profile
)

passport.use new GitHubStrategy(
  clientID: GITHUB_CLIENT_ID
  clientSecret: GITHUB_CLIENT_SECRET
  callbackURL: "http://extended-reader.herokuapp.com/auth/github/callback"
, (accessToken, refreshToken, profile, done) ->
  # User.findOrCreate
  #   githubId: profile.id
  # , (err, user) ->
  #   done err, user
  process.nextTick ->
    done null, profile
)

passport.use new TwitterStrategy(
  consumerKey: TWITTER_CONSUMER_KEY
  consumerSecret: TWITTER_CONSUMER_SECRET
  callbackURL: "http://extended-reader.herokuapp.com/auth/twitter/callback"
, (token, tokenSecret, profile, done) ->
  # User.findOrCreate
  #   twitterId: profile.id
  # , (err, user) ->
  #   done err, user
  process.nextTick ->
    done null, profile
)

passport.use new VKontakteStrategy(
  clientID: VKONTAKTE_APP_ID
  clientSecret: VKONTAKTE_APP_SECRET
  callbackURL: "http://extended-reader.herokuapp.com/auth/vkontakte/callback"
, (accessToken, refreshToken, profile, done) ->
  # User.findOrCreate
  #   vkontakteId: profile.id
  # , (err, user) ->
  #   done err, user
  process.nextTick ->
    done null, profile
)

passport.use new FacebookStrategy(
  clientID: FACEBOOK_APP_ID
  clientSecret: FACEBOOK_APP_SECRET
  callbackURL: "http://extended-reader.herokuapp.com/auth/facebook/callback"
, (accessToken, refreshToken, profile, done) ->
  # User.findOrCreate
  #   facebookId: profile.id
  # , (err, user) ->
  #   done err, user
  process.nextTick ->
    done null, profile
)






db = null
app = express()

# require('nodetime').profile ->
#   accountKey: '92798cace79d721d196c3697e51c1758c40a5147'
#   appName: 'Node.js Application'


require('look').start();

app.use assets()

app.configure ->
  app.set 'port', process.env.PORT or 4000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev') # 'dev'
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


 # Routes
app.get '/', routes.index
app.get '/partials/:name', routes.partials

# JSON API
app.get '/api/books', api.books
app.get '/api/book/:id', api.book
app.post '/api/book', api.addBook
app.put '/api/book/:id', api.saveBookChanges
app.delete '/api/book/:id', api.deleteBook

app.get '/api/readBook/:id', api.readBook
app.get '/api/readByLines/:id', api.readByLines

app.put '/api/save_book/:id', api.saveBook
app.put '/api/book_finished/:id', api.finishBook
app.put '/api/reset_book/:id', api.resetBook
app.put '/api/save_stats/:id', api.saveBookStats

# app.put '/api/addparts/:id', api.addParts
app.get '/api/book_with_text/:id', api.bookWithText
app.put '/api/reset_parts/:id/:plen', api.resetParts


app.get '/api/parts/:id', api.bookParts
app.get '/api/part/:book_id/:num', api.getBookPart
app.put '/api/part/:id', api.savePartTime


app.get '/api/settings', api.settings
app.put '/api/settings/:id', api.saveSettings







# Google Auth

app.get "/auth/google", passport.authenticate("google",
  scope: ["https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"]
), (req, res) ->

app.get "/oauth2callback", passport.authenticate("google",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"


# Github Auth

app.get "/auth/github", passport.authenticate("github"), (req, res) ->

app.get "/auth/github/callback", passport.authenticate("github",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"


# twitter Auth

app.get "/auth/twitter", passport.authenticate("twitter"), (req, res) ->

app.get "/auth/twitter/callback", passport.authenticate("twitter",
  failureRedirect: "/login"
), (req, res) ->
  res.redirect "/"


# vkontakte Auth

app.get "/auth/vkontakte", passport.authenticate("vkontakte"), (req, res) ->

app.get "/auth/vkontakte/callback", passport.authenticate("vkontakte",
  failureRedirect: "/login"
), (req, res) ->
  
  # Successful authentication, redirect home.
  res.redirect "/"


# facebook Auth

app.get "/auth/facebook", passport.authenticate("facebook"), (req, res) ->

app.get "/auth/facebook/callback", passport.authenticate("facebook",
  failureRedirect: "/login"
), (req, res) ->
  
  # Successful authentication, redirect home.
  res.redirect "/"


app.get '/#_=_', (req, res) ->
  res.redirect '/'










# app.get "/login", (req, res) ->
#   res.redirect "/"
#   # res.render "index",
#   #   user: req.user

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"

# redirect all others to the index (HTML5 history)
app.get '*',  (req, res) ->
  res.render "index"


http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')
