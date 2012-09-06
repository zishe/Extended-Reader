fs = require 'fs'
path = require 'path'
models = require './models'

# Count = models.Count
Book = models.Book
Part = models.Part
Settings = models.Settings





# Overloaded mongo methods



# Load Book
LoadBook = (id, cb) ->
  console.log 'loading book...'
  Book.findById id, (err, book) ->
    if err
      console.log err
      throw err
    console.log 'loaded book: ' + book.title
    cb book


# Save Book
SaveBook = (book, cb) ->
  console.log 'saving book...'
  book.save (err) ->
    if err
      console.log err
      throw err
    console.log 'saved book: ' + book.title
    cb()


# Delete Book
DeleteBook = (id, cb) ->
  console.log 'deleting book...'
  Book.remove {_id: id}, (err) ->
    unless err
      console.log 'done'
      cb true
    else
      console.log err
      cb false


# Load Book text
LoadText = (book, cb) ->
  console.log 'loading file...'
  fs.readFile book.path, (err, data) ->
    if err
      console.log err
      throw err
    console.log 'file loaded'
    cb data.toString()


# Save book text in file
SaveText = (book, text) ->
  console.log 'saving text...'
  book.path = __dirname + '/../public/files/' + book._id.toString()
  fs.writeFile book.path, text, (err) ->
    console.log err if err
    console.log "done"


# Delete Text
DeleteText = (book) ->
  # delete file
  if book.path?
    console.log 'deleting book text file...'
    fs.unlink book.path, (err) ->
      console.log err if err
      console.log 'done'



# Load settings or create
LoadSettings = (cb) ->
  console.log 'loading settings...'
  Settings.findOne (err, settings) ->
    console.log err if err
    
    if not settings?
      CreateSettings (settings) ->
        cb settings
    else
      console.log 'settings loaded'
      cb settings


# Create Settings
CreateSettings = (cb) ->
  console.log "creating settings..."
  settings = Settings()
  
  settings.save (err) ->
    console.log err if err
    console.log "settings saved"
    cb settings


SaveSettings = (settings, cb) ->
  console.log "saving settings..."
  settings.save (err) ->
    unless err
      console.log "settings saved"
      cb true
    else
      console.log err
      cb false


# remove all book parts
DeleteBookParts = (id) ->
  # delete all book parts
  console.log 'deleting book parts...'
  Part.where('book').equals(id).remove (err) ->
    console.log err if err
    console.log 'done'


# Count words and chars
getWordsCount = (text) ->
  console.log 'Define words and chars count'
  
  count = {}
  count.chars = text.length
  count.charsWithoutSpaces = text.replace(/\s+/g, '').length
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…]/g, '').replace(/\s+/gi,' ').split(' ').length
  
  console.log 'chars: ' + count.chars
  console.log 'chars wothout spaces: ' + count.charsWithoutSpaces
  console.log 'words count: ' + count.words

  return count


# Calculate Parts
AllocateParts = (book, text, settings, callback) ->
  #words and chars count
  book.count = getWordsCount(text)
  console.log settings

  #make parts
  for i in [0..9]
    if !book.parsed
      savePart(text, book, i, settings.part_length)
  
  console.log 'saving book...'
  book.save (err0) ->
    if err0
      console.log err0
    console.log 'saved'
    callback book


# Select one part
savePart = (text, book, i, min_length) ->
  console.log 'select parts from text'

  #remove used text
  text = text.substr book.lastPosParsed, text.length - 1
  
  if (text.length < 10)
    console.log "end of file"
    book.parsed = true
  else
    # create Part
    part = new Part()
    console.log 'start from ' + book.lastPosParsed + ' position'
    part.startPos = book.lastPosParsed

    #select paragraphs
    paragraph = text.split '\n'
    console.log 'all paragraphs: ' + paragraph.length

    console.log 'min len ' + min_length
    #make one part from paragraphs
    partText = ''
    sPart = '' # without last paragraph
    lastP = ''
    num = 0
    while partText.length < min_length and paragraph.length > num
      sPart = partText
      lastP = paragraph[num]
      partText += paragraph[num] + '\n'
      console.log partText.length
      num++

    console.log 'part generated'

    cutting = false
    #check if part is too long divide by dot
    if partText.length > min_length * 1.3
      console.log 'too long'
      cutting = true
      num = 0
      partText = sPart
      sentence = lastP.split('.')
      console.log 'last part ' + lastP.length + ' contains ' + sentence.length + ' sentences'
      while partText.length < min_length and sentence.length > num
        partText += sentence[num] + '.'
        console.log partText.length
        num++

      partText += '→'


    console.log "length: " + partText.length
    part.text = partText
    part.count = getWordsCount(part.text.replace('→', ''))
    plen = if cutting then partText.length - 1 else partText.length
    book.lastPosParsed += plen
    part.endPos = book.lastPosParsed
    part.num = i

    part.book = book._id
    part.save()









# Export methods



# Get all Books for viewing list and select one
exports.books = (req, res) ->
  Book.find().sort('-created').exec (err, books) ->
    res.json {books: books, user: req.user}


# Get Book for statistics and select exercise
exports.book = (req, res) ->
  LoadBook req.params.id, (book) ->
    res.json book: book


# Get Book with Settings for reading
exports.readBook = (req, res) ->
  LoadBook req.params.id, (book) ->
    LoadPart book._id, book.currPartNum, (part) ->
      LoadSettings (settings) ->
        res.json {book, part, settings}


# Get Book with text for editing
exports.bookWithText = (req, res) ->
  LoadBook req.params.id, (book) ->
    LoadText book, (text) ->
      book.text = text
      #   cb book
      # else
      #   pieceSize = 100000 # symbols
      #   console.log 'text length: ' + text.length
      #   if (text.length > pieceSize)
      #     console.log 'cutting'
      #     text = text.substr 0, pieceSize
      #   cb book, text
      res.json book: book


# Put Book for saving title, author and text, after editing them
exports.saveBookChanges = (req, res) ->
  LoadBook req.params.id, (book) ->
    
    book.title = req.body.title
    book.author = req.body.author
    book.text = null
    
    SaveText book, req.body.text, () ->
      SaveBook book, () ->
        res.json book: book


# Delete Book
exports.deleteBook = (req, res) ->
  id = req.params.id
  LoadBook id, (book) ->

    DeleteText book
    DeleteBook id, (deleted) ->
      res.json deleted
    DeleteBookParts id


# Post Book, save all info and generate first 10 Parts
exports.addBook = (req, res) ->
  console.log 'creating book...'
  book = new Book()
  b = req.body
  book.title = b.title
  book.author = b.author
  
  SaveBook book, () ->
    LoadSettings (settings) ->
      AllocateParts book, b.text, settings, (book) ->
        res.json book:book

    SaveText book, b.text


# Put Book, save changed info and generate parts if need
exports.saveBook = (req, res) ->
  LoadBook req.params.id, (book) ->
    
    console.log 'set count and time params for book ' + book.title
    book.readCount = req.body.readCount
    book.complete = req.body.complete
    book.currPartNum = req.body.currPartNum
    book.readingTime = req.body.readingTime

    SaveBook book, () ->

      console.log 'getting next part...'
      Part.find {book: book._id}, (err1, parts) ->
        console.log err1 if err1
        
        console.log 'open ' + parts.length + ' parts'
        console.log 'current number is ' + book.currPartNum
        
        if parts.length < book.currPartNum + 5
          if book.parsed
            console.log 'book parsed'
          else
            # load settings
            LoadSettings (settings) ->

              console.log 'generate new parts'
              LoadText book, (text) ->
                partsCount = parts.length
                
                for i in [0..9]
                  if !book.parsed
                    savePart(text, book, i + partsCount, settings.part_length)
                
                SaveBook book, () ->
                  
                  console.log 'now getting current part'
                  Part.findOne {book: book._id, num: book.currPartNum}, (err4, part) ->
                    console.log err4 if err4
                    
                    console.log 'return next part'
                    res.json part: part
        else
          Part.findOne {book: book._id, num: book.currPartNum}, (err4, part) ->
            console.log err4 if err4
            
            console.log 'return next part'
            res.json part: part




# Put Book, set finished
exports.finishBook = (req, res) ->
  LoadBook req.params.id, (book) ->
    book.finished = true
    console.log 'set finished'
    SaveBook book, () ->
      res.json true

# Put Book, reset read data
exports.resetBook = (req, res) ->
  LoadBook req.params.id, (book) ->
    setDefaults()
    SaveBook book

  Part.find(book: req.params.id).where('readingTime').gt(0).exec (err, parts) ->
    console.log err if err
    console.log 'get all parts, in count ' + parts.length

    for part in parts
      part.readingTime = null
      part.save (err1) ->
        console.log err1 if err1






LoadPart = (book_id, num, cb) ->
  console.log 'load book part num ' + num
  Part.findOne {book: book_id, num: num}, (err, part) ->
    console.log err if err
    console.log 'loaded book part'
    cb part



# Part

# Get Part
exports.getBookPart = (req, res) ->
  LoadPart req.params.id, req.params.num, (part) ->
    res.json part

# Get Parts for statistics collect
exports.bookParts = (req, res) ->
  console.log 'loading book parts...'
  Part.find {book: req.params.id}, (err, parts) ->
    console.log err if err
    console.log 'get all parts: ' + parts.length
    res.json parts:parts

# Put Part, save reading time (only can change)
exports.savePartTime = (req, res) ->
  console.log 'saving part reading time...'
  Part.findByIdAndUpdate req.params.id, { readingTime: req.body.readingTime }, (err, part) ->
    console.log err if err
    console.log 'set reading time for part ' + part.num
    res.json true



# Update Parts
exports.resetParts = (req, res) ->
  part_length = parseInt(req.params.plen)
  LoadBook req.params.id, (book) ->
    last = book.lastPosParsed
    curr = book.currPartNum

    console.log 'load current part to check last pos'
    Part.findOne {book: book._id, num: curr}, (err1, part) ->


    Part.where('book').equals(book._id).where('num').gt(curr).remove (err2) ->
      console.log err1 if err1
      console.log 'futher parts deleted'

    SaveBook () ->
      console.log 'set num ' + num
      res.json true


# Settings

# Get
exports.settings = (req, res) ->
  LoadSettings (settings) ->
    res.json settings:settings

# Put Settings and save all it params
exports.saveSettings = (req, res) ->
  LoadSettings (settings) ->
    
    settings.font_size = req.body.font_size
    settings.line_height = req.body.line_height
    settings.width = req.body.width
    settings.part_length = req.body.part_length
    settings.words_font_size = req.body.words_font_size
    settings.words_count = req.body.words_count
    
    SaveSettings (succ) ->
      res.json succ
