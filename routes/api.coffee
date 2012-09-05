fs = require 'fs'
path = require 'path'
models = require './models'

# Count = models.Count
Book = models.Book
Part = models.Part
Settings = models.Settings

# processed queries

# Get all Books for viewing list and select one
exports.books = (req, res) ->
  Book.find().sort('-created').exec (err, books) ->
    res.json {books: books, user: req.user}

# Get Book for statistics and select exercise
exports.book = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log err if err
    res.json book: book

# Get Book with Settings for reading
exports.readBook = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log err if err
    
    Part.findOne {book: book._id, num: book.currPartNum}, (err0, part) ->
      console.log err0 if err0

      Settings.findOne (err1, settings) ->
        console.log err if err1
        
        if not settings?
          console.log "create settings"
          settings = Settings()
          
          settings.save (err2) ->
            console.log err2 if err2
            res.json {book, part, settings}
        else
          res.json {book, part, settings}

# Get Book with text for editing
exports.bookWithText = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log err if err
    console.log "read file"
    
    fs.readFile book.path, (err1, data) ->
      console.log err if err1
      book.text = data.toString()
      
      res.json book: book

# Put Book for saving title, author and text, after editing them
exports.editBook = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log err if err

    book.title = req.body.title
    book.author = req.body.author
    book.text = null
    
    console.log "save text in file"
    fs.writeFile book.path, req.body.text, (err1) ->
      console.log err1 if err1
      console.log "saved"

      book.save (err2) ->
        console.log err2 if err2
        res.json book: book

# Delete Book
exports.deleteBook = (req, res) ->
  id = req.params.id
  Book.findById id, (err, book) ->
    console.log err if err
    
    # delete file
    if book.path?
      console.log 'delete book text file'
      fs.unlink book.path, (err1) ->
        console.log err1 if err1
        console.log 'deleted'
    
    # delete Book document
    Book.remove {_id: id}, (err2, book) ->
      unless err2
        console.log book.path
        res.json true
      else
        console.log err2
        res.json false
    
    # delete all book parts
    Part.where('book').equals(book._id).remove (err1) ->
      console.log err1 if err1
      console.log 'all parts removed'










# Post Book, save all info and generate first 10 Parts
exports.addBook = (req, res) ->
  
  #create book
  book = new Book()
  b = req.body
  book.title = b.title
  book.author = b.author
  
  # first save
  book.save (err) ->
    console.log err if err
    console.log 'book saved: ' + book.title
    
    LoadSettings book, b.text, (settings) ->
      AllocateParts book, b.text, settings, (book) ->
        res.json book:book

    SaveText book, b.text


# Save book text in file
SaveText = (book, text) ->
  console.log 'saving text'
  book.path = __dirname + '/../public/files/' + book._id.toString()
  fs.writeFile book.path, text, (err) ->
    console.log err if err
    console.log "text saved in file"


# Load settings or create
LoadSettings = (book, text, callback) ->
  console.log 'load settings'
  Settings.findOne (err, settings) ->
    console.log err if err
    
    if not settings?
      console.log "create settings"
      settings = Settings()
      
      settings.save (err1) ->
        console.log err1 if err1
        console.log "settings saved"
        callback settings
    else
      callback settings


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

































# Put Book, save changed info and generate parts if need
exports.saveBook = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    console.log err if err
    
    book.readCount = req.body.readCount;
    book.complete = req.body.complete;
    book.currPartNum = req.body.currPartNum;
    book.readingTime = req.body.readingTime;
    console.log 'set count and time params for book ' + book.title

    book.save (err0) ->
      console.log err0 if err0
      console.log 'saved book'

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
            Settings.findOne (err6, settings) ->
              console.log err6 if err6
              console.log 'settings loaded'

              console.log 'generate new parts'
              fs.readFile book.path, (err2, data) ->
                console.log err2 if err2
                console.log 'read file'
                partsCount = parts.length
                
                for i in [0..9]
                  if !book.parsed
                    savePart(data.toString(), book, i + partsCount, settings.part_length)
                
                console.log 'saving book'
                book.save (err3) ->
                  console.log err3 if err3
                  console.log 'saved book for position change'
                  
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
  Book.findById req.params.id, (err, book) ->
    book.finished = true;
    console.log 'set finished'
    book.save (err1) ->
      console.log err1 if err1
      console.log 'saved book'

# Put Book, reset read data
exports.resetBook = (req, res) ->
  Book.findById req.params.id, (err, book) ->
    setDefaults()

    book.save (err1) ->
      console.log err1 if err1
      console.log 'saved book'

  Part.find(book: req.params.id).where('readingTime').gt(0).exec (err, parts) ->
    console.log err if err
    console.log 'get all parts, in count ' + parts.length

    for part in parts
      part.readingTime = null
      part.save (err1) ->
        console.log err1 if err1





# Part

# Get Part
exports.getBookPart = (req, res) ->
  Part.findOne {book: req.params.id, num: req.params.num}, (err, part) ->
    console.log err if err
    console.log 'get part number ' + req.params.num
    res.json part

# Get Parts for statistics collect
exports.bookParts = (req, res) ->
  Part.find {book: req.params.id}, (err, parts) ->
    console.log err if err
    console.log 'get all parts, in count ' + parts.length
    res.json parts:parts

# Put Part, save reading time (only can change)
exports.savePartTime = (req, res) ->
  Part.findByIdAndUpdate req.params.id, { readingTime: req.body.readingTime }, (err, part) ->
    console.log err if err
    console.log 'set reading time for part ' + part.num
    res.json true

# Update Parts
exports.resetParts = (req, res) ->
  part_length = parseInt(req.params.plen)
  console.log 'load book'
  Book.findById req.params.id, (err, book) ->
    last = book.lastPosParsed
    curr = book.currPartNum

    console.log 'load current part to check last pos'
    Part.findOne {book: book._id, num: curr}, (err1, part) ->


    Part.where('book').equals(book._id).where('num').gt(curr).remove (err2) ->
      console.log err1 if err1
      console.log 'futher parts deleted'

    book.save () ->
      console.log 'set num ' + num
      res.json true





# Settings

# Get
exports.settings = (req, res) ->
  Settings.findOne (err, settings) ->
    console.log err if err
    console.log 'load settings'
    res.json settings:settings

# Put Settings and save all it params
exports.saveSettings = (req, res) ->
  Settings.findById req.params.id, (err, settings) ->
    console.log err if err
    console.log req.body
    # settings = req.body
    
    settings.font_size = req.body.font_size
    settings.line_height = req.body.line_height
    settings.width = req.body.width
    settings.part_length = req.body.part_length
    settings.words_font_size = req.body.words_font_size
    settings.words_count = req.body.words_count
    
    settings.save (err1, s) ->
      unless err1
        console.log "settings saved"
        console.log s
      else
        console.log err1
      res.json true



