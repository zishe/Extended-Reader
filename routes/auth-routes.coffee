module.exports = (app, passport) ->

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
