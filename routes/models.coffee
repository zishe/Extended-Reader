mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

PartSchema = new Schema(
  startPos: Number
  endPos: Number
  lengthChars: Number
  countWords: Number
  # num: Number
  text: String
  readingTime: Number
)

BookSchema = new Schema(
  title: String
  author: String
  text: String
  count:
    words: Number
    chars: Number
    charsNoSpaces: Number
  lastPos: Number
  partNum: Number
  # currPart: PartSchema
  parts: [PartSchema]
  reading: Boolean
  endRead: Boolean
  path: String
  created:
    type: Date
    default: Date.now
)


mongoose.model "Part", PartSchema
Part = mongoose.model "Part"
exports.Part = Part

mongoose.model "Book", BookSchema
Book = mongoose.model "Book"
exports.Book = Book


Part.on 'error', (err) ->
  console.log "Got an error", err

Book.on 'error', (err) ->
  console.log "Got an error", err


UserSettingsSchema = new Schema(
  font_size: Number
  line_height: Number
  width: Number
  part_length: Number
)

mongoose.model "UserSettings", UserSettingsSchema
UserSettings = mongoose.model "UserSettings"
exports.UserSettings = UserSettings
