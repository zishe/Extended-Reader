# https://github.com/jaredhanson/passport-google-oauth/blob/master/examples/oauth2/app.js

module.exports = (passport) ->

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
