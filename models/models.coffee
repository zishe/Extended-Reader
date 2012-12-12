mongoose = require 'mongoose'
timestamps = require 'mongoose-time'

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

mongoose.set 'debug', true


Count = {
  words:                { type: Number, default: 0 }
  chars:                { type: Number, default: 0 }
  chars_without_spaces: { type: Number, default: 0 }
}


PartSchema = new Schema(
  book:         { type: ObjectId, ref: 'Reading' }

  start_pos:    Number
  end_pos:      Number
  count:        Count

  num:          Number
  text:         String
  reading_time: Number
  finished:     Date
)


BookSchema = new Schema(
  title:  { type: String, required: true }
  path:   String
  author: String
  text:   String
  count:  Count

  # updated: Date
  # created: Date
).plugin(timestamps())



ReadingBookSchema = new Schema(
  book:             { type: ObjectId, ref: 'Book' }
  count:            Count

  last_pos_parsed:  { type: Number, default: 0 }
  complete:         { type: Number, default: 0 }
  reading_time:     { type: Number, default: 0 }
  read_count:       Count

  current_part_num: { type: Number, default: 0 }
  regen_parts:      { type: Boolean, default: false }
  parts:            [{ type: ObjectId, ref: "Part" }]
  finished:         { type: Boolean, default: false }
  parsed:           { type: Boolean, default: false }

  # updated: Date
  # created: Date

).plugin(timestamps())


SpeedReadingSchema = new Schema(
  book:             { type: ObjectId, ref: 'Book' }
  count:            Count

  complete:         { type: Number, default: 0 }
  reading_time:     { type: Number, default: 0 }
  read_count:       Count

  last_word_pos:    { type: Number, default: 0 }
  finished:         { type: Boolean, default: false }

  # updated: Date
  # created: Date

).plugin(timestamps())

# BookSchema.pre "save", (next) ->
#   if @isNew
#     @created = @updated = new Date()
#   else
#     @updated = new Date()
#   next()


SettingsSchema = new Schema(
  font_size:        { type: Number, default: 22 }
  line_height:      { type: Number, default: 33 }
  width:            { type: Number, default: 820 }
  part_length:      { type: Number, default: 1000 }

  words_font_size:  { type: Number, default: 31 }
  words_count:      { type: Number, default: 3 }
  words_delay:      { type: Number, default: 300 }
  words_speed:      { type: Number, default: 230 }
  words_length:     { type: Number, default: 15 }

  mem_length:       { type: Number, default: 1 }
  mem_part:         { type: String, default: "sentence" }
)


Part = mongoose.model "Part", PartSchema
exports.Part = Part

Book = mongoose.model "Book", BookSchema
exports.Book = Book

ReadingBook = mongoose.model "ReadingBook", ReadingBookSchema
exports.ReadingBook = ReadingBook

SpeedReading = mongoose.model "SpeedReading", SpeedReadingSchema
exports.SpeedReading = SpeedReading

Settings = mongoose.model "Settings", SettingsSchema
exports.Settings = Settings


Part.on 'error', (err) ->
  console.log "Got an error", err

Book.on 'error', (err) ->
  console.log "Got an error", err

ReadingBook.on 'error', (err) ->
  console.log "Got an error", err

SpeedReading.on 'error', (err) ->
  console.log "Got an error", err

Settings.on 'error', (err) ->
  console.log "Got an error", err
