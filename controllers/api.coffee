fs = require 'fs'
path = require 'path'
models = require '../models/models'

# Count = models.Count
Book = models.Book
Reading = models.Reading
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
    cb


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




# Load Reading
LoadReading = (id, cb) ->
  console.log 'loading reading...'
  Reading.findById id, (err, reading) ->
    if err
      console.log err
      throw err
    console.log 'loaded reading: ' + reading._id
    cb reading


# Save Reading
SaveReading = (reading, cb) ->
  console.log 'saving reading...'
  reading.save (err) ->
    if err
      console.log err
      throw err
    console.log 'saved reading: ' + reading._id
    cb()


# Delete Reading
DeleteReading = (id, cb) ->
  console.log 'deleting reading...'
  Reading.remove {_id: id}, (err) ->
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
      # throw err
    console.log 'file loaded'
    if data
      cb data.toString()
    else
      cb null


# Save book text in file
SaveText = (book, text) ->
  console.log 'saving text...'
  book.path = __dirname + '/../upload/files/' + book._id.toString()
  console.log(book.path);

  fs.writeFile book.path, text.trim(), (err) ->
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
getCount = (text) ->
  console.log 'Define words and chars count'

  count = {}
  count.chars = text.length
  count.symbols = text.replace(/\s+/g, '').length
  count.words = text.replace(/[\,\.\:\?\-\—\;\(\)\«\»\…\!\[\]]/g, '').replace(/\s+/gi,' ').trim().split(' ').length

  console.log 'chars: ' + count.chars
  console.log 'chars wothout spaces: ' + count.symbols
  console.log 'words count: ' + count.words

  return count






# Calculate Parts
CalculateParts = (reading, text, settings, callback) ->
  console.log settings

  #make parts
  for i in [0..9]
    unless reading.parsed
      part = getNextPart(text, reading, i, settings.part_length)
      part.save()

  console.log 'saving reading...'
  reading.save (err) ->
    if err
      console.log err
    console.log 'saved'
    callback reading


# Select one part
getNextPart = (text, reading, i, min_length) ->
  console.log 'select parts from text'

  #remove used text
  text = text.substr reading.last_pos_parsed, text.length - 1

  #parsed
  if (text.length < 10)
    console.log "end of file"
    reading.parsed = true

  else
    # create Part
    part = new Part()

    # set start position
    console.log 'start from ' + reading.last_pos_parsed + ' position'
    part.start_pos = reading.last_pos_parsed

    #select paragraphs
    paragraph = text.split '\n'
    console.log 'all paragraphs: ' + paragraph.length

    #make one part from paragraphs
    part_text = ''
    prev_part = '' # without last paragraph
    last_p = '' # last paragraph
    num = 0 # paragraph number
    while part_text.length < min_length and paragraph.length > num
      prev_part = part_text
      last_p = paragraph[num]
      part_text += paragraph[num] + '\n'
      console.log part_text.length
      num++

    console.log 'part generated'

    # check if part is too long - divide by dot
    if part_text.length > min_length * 1.3
      console.log 'too long'
      num = 0

      part_text = prev_part
      sentence = last_p.split('.')
      console.log 'last part ' + last_p.length + ' contains ' + sentence.length + ' sentences'

      while part_text.length < min_length and sentence.length > num
        part_text += sentence[num] + '.'
        console.log part_text.length
        num++

      part_text += '→'


    console.log "length: " + part_text.length
    part.text = part_text
    part.count = getCount(part.text.replace('→', ''))
    reading.last_pos_parsed += part.count.chars
    part.end_pos = reading.last_pos_parsed
    part.num = i

    part.reading = reading._id
    return part









# Export methods



# Get all Books for viewing list and select one
exports.books = (req, res) ->
  Book.find().sort('-updated').populate('reading').exec (err, books) ->
    res.json {books: books, user: req.user}


# Get Book for statistics
exports.book = (req, res) ->
  LoadBook req.params.id, (book) ->
    res.json book: book


# Get Book with Settings for reading
exports.readBook = (req, res) ->
  LoadBook req.params.id, (book) ->
    LoadPart book._id, book.current_part_num, (part) ->
      LoadSettings (settings) ->
        res.json {book, part, settings}


# Get Book with text for editing
exports.bookWithText = (req, res) ->
  LoadBook req.params.id, (book) ->
    LoadText book, (text) ->
      book.text = text
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


# Post Book, save all info
exports.addBook = (req, res) ->
  console.log 'creating book...'
  book = new Book()

  b = req.body
  book.title = b.title
  book.author = b.author

  book.count = getCount(b.text)
  book.count.chars++
  console.log JSON.stringify(book)

  SaveBook book, () ->
    # LoadSettings (settings) ->
    #   #words and chars count
    #   reading.count = getCount(text)
    #   reading.count.chars++

    #   CalculateParts book, b.text, settings, (book) ->
    #     res.json book:book
    res.json book:book
    SaveText book, b.text















Fiber = require('fibers')
libxmljs = require("libxmljs")
xslt = require('node_xslt')


sleep = (ms) ->
  fiber = Fiber.current
  setTimeout (->
    fiber.run()
  ), ms
  Fiber.yield()


# Post Book, save all info and generate first 10 Parts
exports.uploadFile = (req, res) ->
  console.log 'uploading file...'
  # console.log req.files.uploadedFile
  Fiber(->
    u = req.files.uploadedFile
    sleep 1000

    if u instanceof Array
      console.log "array"
      saveFile file for file in u
    else
      saveFile u
  ).run()


saveFile = (file) ->
  console.log file.path
  console.log file.name
  newPath = __dirname + "/upload/" + file.name
  console.log newPath
  if /.fb2$/.test(file.name)
    console.log("fb2 file")

    fs.readFile file.path, 'utf8', (err, data) ->
      if err
        console.log err
      # console.log data
      xmlDoc = libxmljs.parseXml(data)
      # console.log xmlDoc.toString()
      gchild = xmlDoc.get('//description')
      console.log gchild.text()
      # console.log xmlDoc.root().text()


      # stylesheet = fs.readFileSync('/home/alder/Node/Speed-reading-apps/src/scripts/libs/FB2_2_txt.xsl', 'utf8')
      # # console.log stylesheet

      # transformedString = xslt.transform stylesheet, xmlDoc, []
      # console.log transformedString

      # .replace(/(<([^>]+)>)/ig,"");
      # xpath queries
      # children = xmlDoc.root().childNodes()
      # child = children[0]
      # console.log child.attr("foo").value()
      # $('#text').xslt(body, 'FB2_2_xhtml.xsl')






# Put Book, save changed info and generate parts if need
exports.saveBook = (req, res) ->
  LoadBook req.params.id, (book) ->

    console.log 'set count and time params for book ' + book.title
    book.read_count = req.body.read_count
    book.complete = req.body.complete
    book.current_part_num = req.body.current_part_num
    book.reading_time = req.body.reading_time

    SaveBook book, () ->

      console.log 'getting next part...'
      Part.find {book: book._id}, (err1, parts) ->
        console.log err1 if err1

        console.log 'open ' + parts.length + ' parts'
        console.log 'current number is ' + book.current_part_num

        if (parts.length < book.current_part_num + 5) and not book.parsed
            LoadSettings (settings) ->

              console.log 'generate new parts'
              LoadText book, (text) ->
                partsCount = parts.length

                for i in [0..9]
                  if !book.parsed
                    part = getNextPart(text, book, i + partsCount, settings.part_length)
                    part.save()

                SaveBook book, () ->

                  console.log 'now getting current part'
                  Part.findOne {book: book._id, num: book.current_part_num}, (err4, part) ->
                    console.log err4 if err4

                    console.log 'return next part'
                    res.json part: part
        else
          Part.findOne {book: book._id, num: book.current_part_num}, (err4, part) ->
            console.log err4 if err4

            console.log 'return next part'
            res.json part: part


# Save stats
exports.saveBookStats = (req, res) ->
  LoadBook req.params.id, (book) ->

    console.log 'set count and time params for book ' + book.title
    book.read_count = req.body.read_count
    book.complete = req.body.complete
    book.current_part_num = req.body.current_part_num
    book.reading_time = req.body.reading_time
    book.last_word_pos = req.body.last_word_pos

    SaveBook book, () ->
      res.json book





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
    book.read_count = {}
    book.read_count.words = 0
    book.read_count.chars = 0
    book.read_count.symbols = 0

    book.complete = 0
    book.reading_time = 0
    book.current_part_num = 0
    book.last_word_pos = 0

    book.finished = false

    SaveBook book, () ->
      res.json book:book

  Part.find(book: req.params.id).where('reading_time').gt(0).exec (err, parts) ->
    console.log err if err
    console.log 'get all parts, in count ' + parts.length

    for part in parts
      part.reading_time = null
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
  LoadPart req.params.book_id, req.params.num, (part) ->
    res.json part:part

# Get Parts for statistics collect
exports.bookParts = (req, res) ->
  console.log 'loading book parts...'
  Part.find().where('book').equals(req.params.id).sort('num').exec (err, parts) ->
    console.log err if err
    console.log 'get all parts: ' + parts.length
    res.json parts:parts

# Put Part, save reading time (only can change)
exports.savePartTime = (req, res) ->
  console.log 'saving part reading time...'
  Part.findByIdAndUpdate req.params.id, { reading_time: req.body.reading_time }, (err, part) ->
    console.log err if err
    console.log 'set reading time for part ' + part.num
    res.json true



# Update Parts
exports.resetParts = (req, res) ->
  part_length = parseInt(req.params.plen)
  LoadBook req.params.id, (book) ->
    last = book.last_pos_parsed
    curr = book.current_part_num

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
    console.log settings
    console.log req.body
    console.log 'copy fields'

    props = ['font_size', 'line_height', 'width', 'part_length', 'words_font_size', 'words_count', 'words_delay', 'words_speed', 'words_length', 'mem_length', 'mem_part']
    for prop in props
      do (prop) ->
        settings[prop] = req.body[prop]

    SaveSettings settings, (succ) ->
      console.log 'saved'
      res.json succ
