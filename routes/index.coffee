exports.index = (req, res) ->
  res.render "index"

exports.partials = (req, res) ->
  name = req.params.name
  res.render "partials/" + name

exports.login = (req, res) ->
  res.render 'login'