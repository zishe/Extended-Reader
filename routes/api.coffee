fs = require 'fs'
path = require 'path'

mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

BookSchema = new Schema(
  title:String
  author: String
  text: String
  count:
    words: Number
    chars: Number
    charsNoSpaces: Number
  currPart: String
  lastPos: Number
  nextParts: [String]
  prevParts: [String]
  path: String
  created:
    type: Date
    default: Date.now
)


mongoose.model "Book", BookSchema
Book = mongoose.model "Book"
exports.Book = Book

handleError = (err) ->
  if err
    console.log err
    throw err

Book.on('error', handleError)


UserSettingsSchema = new Schema(
  font_size: Number
  line_height: Number
  width: Number
  part_length: Number
)

mongoose.model "UserSettings", UserSettingsSchema
UserSettings = mongoose.model "UserSettings"
exports.UserSettings = UserSettings

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
    if !err
      book.title = req.body.title
      book.author = req.body.author
      book.text = req.body.text
      book.save (err1) ->
        res.json book: book

exports.deleteBook = (req, res) ->
  id = req.params.id
  Book.findById req.params.id, (err, book) ->
    if !err
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
    newPath = __dirname + '/../public/files/' + book._id.toString()
    book.path = newPath
    console.log newPath

    #words count
    setWordsCount(book, b.text)
    console.log 'check counts: ' + book.count.words

    #make parts
    book.lastPos = 0
    getPart(b.text, book, 500) for i in [0..10]
    #set first part
    book.currPart = book.nextParts.shift()
    book.prevParts = []
    console.log 'parts num: ' + book.nextParts.length
    
    console.log 'saving book...'
    book.save (arr0) ->
      if arr0
        console.log arr0
      console.log 'saved'
      
      fs.writeFile newPath, b.text, (err1) ->
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



getPart = (text, book, min_length) ->
  console.log 'select parts from text'
  console.log 'last pos: ' + book.lastPos
  #remove used text
  text = text.substr book.lastPos, text.length - 1
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
  
  console.log next

  book.lastPos += next.length
  book.nextParts.push next



setWordsCount = (book, text) ->
  console.log 'Define words and chars count'
  
  book.count.chars = text.length
  book.count.charsNoSpaces = text.replace(/\s+/g, '').length
  clean = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, '').replace(/\s+/gi,' ')
  book.count.words = clean.split(' ').length
  
  console.log 'chars: ' + book.count.chars
  console.log 'chars wothout spaces: ' + book.count.charsNoSpaces
  console.log 'words count: ' + clean.split(' ').length
