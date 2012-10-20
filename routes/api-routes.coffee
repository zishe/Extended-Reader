module.exports = (app, api) ->

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
