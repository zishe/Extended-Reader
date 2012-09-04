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

  # timing: Boolean
  finished: Boolean
  parsed: Boolean

  path: String
  created:
    type: Date
    default: Date.now
)

SettingsSchema = new Schema(
  font_size:
    type: Number
    default: 22
  line_height:
    type: Number
    default: 33
  width: Number
    type: Number
    default: 820
  part_length:
    type: Number
    default: 800
  words_font_size:
    type: Number
    default: 31
  words_count:
    type: Number
    default: 3
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
