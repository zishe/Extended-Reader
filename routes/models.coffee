mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

Count = {
  words:
    type: Number
    default: 0
, chars:
    type: Number
    default: 0
, charsWithoutSpaces:
    type: Number
    default: 0
}

PartSchema = new Schema(
  book:
    type: ObjectId
    ref: 'Book'

  startPos: Number
  endPos: Number
  count: Count

  num: Number
  text: String
  readingTime: Number
  finished: Date
)

BookSchema = new Schema(
  title:
    type: String
    required: true
  
  author: String
  text: String
  
  count: Count
  
  lastPosParsed:
    type: Number
    default: 0
  
  complete:
    type: Number
    default: 0
  readingTime:
    type: Number
    default: 0
  
  readCount: Count
  
  currPartNum:
    type: Number
    default: 0
  
  lastWordPos:
    type: Number
    default: 0

  RegenParts:
    type: Boolean
    default: false

  parts: [
    type: ObjectId
    ref: "Part"
  ]

  finished:
    type: Boolean
    default: false
  parsed:
    type: Boolean
    default: false

  path: String

  lastUse: Date
  created:
    type: Date
    default: Date.now
)

BookSchema.pre 'save', (next) ->
  this['lastUse'] = new Date
  next()


SettingsSchema = new Schema(
  font_size:
    type: Number
    default: 22
  line_height:
    type: Number
    default: 33
  width:
    type: Number
    default: 820
  part_length:
    type: Number
    default: 1000
  words_font_size:
    type: Number
    default: 31
  words_count:
    type: Number
    default: 3
  show_delay:
    type: Number
    default: 300
)


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

Settings.on 'error', (err) ->
  console.log "Got an error", err
