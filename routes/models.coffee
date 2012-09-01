mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

CountSchema = { words: Number, chars: Number, charsWithoutSpaces: Number}

PartSchema = new Schema(
  book:
    type: ObjectId
    ref: 'Book'

  startPos: Number
  endPos: Number
  count: CountSchema

  num: Number
  text: String
  readingTime: Number
)

BookSchema = new Schema(
  title: String
  author: String
  text: String
  
  count: CountSchema
  
  lastPosParsed: Number
  complete: Number
  readingTime: Number
  readCount: CountSchema

  currPartNum: Number
  # currPart: PartSchema
  
  parts: [
    type: ObjectId
    ref: "Part"
  ]

  timing: Boolean
  finished: Boolean
  parsed: Boolean

  path: String
  created:
    type: Date
    default: Date.now
)

SettingsSchema = new Schema(
  font_size: Number
  line_height: Number
  width: Number
  part_length: Number
  words_font_size: Number
  words_count: Number
)


# Count = mongoose.model "Count", CountSchema
# exports.Count = Count

Part = mongoose.model "Part", PartSchema
exports.Part = Part

Book = mongoose.model "Book", BookSchema
exports.Book = Book

Settings = mongoose.model "Settings", SettingsSchema
exports.Settings = Settings


Part.on 'error', (err) ->
  console.log "Got an error", err

Book.on 'error', (err) ->
  console.log "Got an error", err
