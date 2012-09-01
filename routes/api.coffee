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
  Book.find {}, (err, books) ->
    res.json books: books

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
          settings = Settings({font_size: 22, line_height: 33, width: 820, part_length: 1000})
          
          settings.save (err2) ->
            console.log err if err2
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
    
    if book.path?
      console.log 'delete book text file'
      fs.unlink book.path, (err1) ->
        console.log err1 if err1
        console.log 'deleted'
    
    Book.remove {_id: id}, (err2, book) ->
      unless err2
        console.log book.path
        res.json true
      else
        console.log err2
        res.json false


# Post Book, save all info and generate first 10 Parts
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

    #words and chars count
    book.count = getWordsCount(b.text)
    console.log 'check count: ' + book.count.words
    
    book.complete = 0
    book.readingTime = 0
    book.readCount = {words: 0, chars: 0, charsWithoutSpaces: 0}
    book.lastPosParsed = 0
    book.currPartNum = 0

    book.timing = false
    book.finished = false
    book.parsed = false
    console.log 'set start params'

    #make parts
    for i in [0..9]
      if !book.parsed
        savePart(b.text, book, i, 1000) 
    
    #set current part
    Part.findOne {book: book._id, num: book.currPartNum}, (err3, cpart) ->
      if err3
        console.log err3
      else
        console.log cpart
      book.currPart = cpart
      console.log 'parts num: ' + book.parts.length
      
      console.log 'saving book...'
      book.save (err0) ->
        if err0
          console.log err0
        console.log 'saved'
        
        fs.writeFile book.path, b.text, (err1) ->
          if err1
            console.log err1
          console.log "text saved in file"
          res.json true

        # #load settings
        # Settings.findOne (err2, settings) ->
        #   if not settings?
        #     console.log "create settings"
        #     settings = Settings({font_size: 16, line_height: 24, width: 640, part_length: 1000})
        #     settings.save()

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
            
            console.log 'generate new parts'
            fs.readFile book.path, (err2, data) ->
              console.log err2 if err2
              console.log 'read file'
              partsCount = parts.length
              
              for i in [0..9]
                if !book.parsed
                  savePart(data.toString(), book, i + partsCount, 1000)
              
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

# Get Parts for statistics collect
exports.bookParts = (req, res) ->
  Part.find {book: req.params.id}, (err, parts) ->
    console.log err if err
    console.log 'get all parts, in count ' + parts.length
    res.json parts:parts

# Put Part, save reading time (only can change)
exports.savePartTime = (req, res) ->
  Part.findById req.params.id, (err, part) ->
    console.log err if err
    part.readingTime = req.body.readingTime
    console.log 'set reading time for part ' + part.num
    part.save (err1) ->
      console.log err1 if err1
      console.log 'saved part'
      res.json true


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




# exports.resetParts = (req, res) ->
#   part_length = parseInt(req.params.pid)
#   Book.findById req.params.id, (err, book) ->
    # book.parts[book.partNum].readingTime = time;
    # book.save () ->
    #   console.log 'set num ' + num
    #   res.json true


savePart = (text, book, i, min_length) ->
  console.log 'select parts from text'
  console.log 'last pos: ' + book.lastPosParsed

  #remove used text
  text = text.substr book.lastPosParsed, text.length - 1
  
  if (text.length < 10)
    console.log "end of file"
    book.parsed = true
  else
    # create Part
    part = new Part()
    part.startPos = book.lastPosParsed

    #select paragraphs
    paragraph = text.split '\n'
    console.log 'all paragraphs: ' + paragraph.length

    #make one part
    partText = ''
    num = 0
    while partText.length < min_length and paragraph.length > num
      partText += paragraph[num] + '\n'
      # console.log num
      # console.log (paragraph[num]).length if paragraph.length > 0
      num++
    
    console.log "length: " + partText.length
    part.text = partText
    part.count = getWordsCount(part.text)
    book.lastPosParsed += partText.length
    part.endPos = book.lastPosParsed
    part.num = i

    part.book = book._id
    part.save()


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
