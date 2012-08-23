fs = require 'fs'
path = require 'path'
models = require './models'
Book = models.Book
Part = models.Part
UserSettings = models.UserSettings

exports.books = (req, res) ->
  Book.find {}, (err, books) ->
    res.json books: books

exports.book = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    # if not UserSettings.findOne()
    UserSettings.findOne (err1, settings) ->
      if not settings?
        console.log "create settings"
        settings = UserSettings({font_size: 16, line_height: 24, width: 640, part_length: 1000})
        settings.save()
      #define text part
      res.json {book, settings}


exports.bookWithText = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log "read file"
    fs.readFile book.path, (err2, data) ->
      book.text = data.toString()
      res.json book: book


exports.editBook = (req, res) ->
  Book.findById req.params.id, (err, book) ->
      if err
        console.log err
      
      book.title = req.body.title
      book.author = req.body.author
      book.text = null
      
      fs.writeFile book.path, req.body.text, (err1) ->
        if err1
          console.log err1
        console.log "text saved in file"

        book.save (err2) ->
          if err2
            console.log err2
          res.json book: book

exports.deleteBook = (req, res) ->
  id = req.params.id
  Book.findById req.params.id, (err, book) ->
    if !err
      if book.path?
        fs.unlink book.path, (err1) ->
          if err1
            console.log err1
    Book.remove {_id: id}, (err2, book) ->
      unless err2
        console.log book.path
        res.json true
      else
        res.json false


exports.saveSettings = (req, res) ->
  id = req.params.id
  UserSettings.findById req.params.id, (err, settings) ->
    settings.font_size = req.body.font_size
    settings.line_height = req.body.line_height
    settings.width = req.body.width
    settings.save (err1) ->
      unless err1
        console.log "saved"


exports.addBook = (req, res) ->
  #create book
  book = new Book()
  b = req.body
  book.title = b.title
  book.author = b.author
  
  book.save (err) ->
    if err
      console.log err
    else
      console.log 'book saved: ' + book.title
    
    #path
    book.path = __dirname + '/../public/files/' + book._id.toString()
    console.log book.path

    #words count
    setWordsCount(book, b.text)
    console.log 'check counts: ' + book.count.words

    book.reading = false
    book.endRead = false
    #make parts
    book.lastPos = 0
    for i in [0..9]
      if !book.endRead
        getPart(b.text, book, 800) 
    #set first part
    book.partNum = 0
    # book.currPart = book.parts[book.partNum]
    console.log 'parts num: ' + book.parts.length
    
    console.log 'saving book...'
    book.save (arr0) ->
      if arr0
        console.log arr0
      console.log 'saved'
      
      fs.writeFile book.path, b.text, (err1) ->
        if err1
          console.log err1
        console.log "text saved in file"
        res.json book: book

      #load settings
      UserSettings.findOne (err2, settings) ->
        if not settings?
          console.log "create settings"
          settings = UserSettings({font_size: 16, line_height: 24, width: 640, part_length: 1000})
          settings.save()



exports.setNum = (req, res) ->
  num = parseInt(req.params.pid)
  Book.findById req.params.id, (err, book) ->
    book.partNum = num
    # book.reading = false
    book.save () ->
      console.log 'set num ' + num
      res.json true


exports.setTime = (req, res) ->
  num = parseInt(req.params.pid)
  time = req.body.time
  console.log time
  Book.findById req.params.id, (err, book) ->
    book.parts[num].readingTime = time;
    book.save () ->
      console.log 'set num ' + num
      res.json true


exports.addParts = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    num = 0
    while num < (book.parts.length - 10)
      if (book.parts[num].text != null)
        console.log 'remove text part number ' + num
        book.parts[num].text = null
      num++
    book.save (err3) ->
      if err3
        console.log err3
      console.log "read file"
      fs.readFile book.path, (err2, data) ->
        for i in [0..4]
          if !book.endRead
            getPart(data.toString(), book, 800)
        book.save (arr0) ->
          if arr0
            console.log arr0

          console.log 'saved'
          res.json book: book


getPart = (text, book, min_length) ->
  console.log 'select parts from text'
  console.log 'last pos: ' + book.lastPos

  #remove used text
  text = text.substr book.lastPos, text.length - 1
  
  if (text.length < 10)
    console.log "end of file"
    book.endRead = true
  else
    # create Part
    part = new Part()
    part.startPos = book.lastPos

    #select paragraphs
    paragraph = text.split '\n'
    console.log 'paragraphs: ' + paragraph.length

    #make one part
    next = ''
    num = 0
    while next.length < min_length and paragraph.length > num
      next += paragraph[num] + '\n'
      # console.log num
      # console.log (paragraph[num]).length if paragraph.length > 0
      num++
    
    console.log "next length: " + next.length
    part.text = next
    part.lengthChars = next.length
    part.countWords = next.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, '').replace(/\s+/gi,' ').split(' ').length
    book.lastPos += next.length
    part.endPos = book.lastPos

    book.parts.push part



setWordsCount = (book, text) ->
  console.log 'Define words and chars count'
  
  book.count.chars = text.length
  book.count.charsNoSpaces = text.replace(/\s+/g, '').length
  clean = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, '').replace(/\s+/gi,' ')
  book.count.words = clean.split(' ').length
  
  console.log 'chars: ' + book.count.chars
  console.log 'chars wothout spaces: ' + book.count.charsNoSpaces
  console.log 'words count: ' + clean.split(' ').length
