fs = require 'fs'

mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

BookSchema = new Schema(
  filepath:
    type: String
    index:
      unique: true
  filename: String
  created:
    type: Date
    default: Date.now
)

mongoose.model "Book", BookSchema
Book = mongoose.model "Book"
exports.Book = Book

exports.books = (req, res) ->
  Book.find {}, (err, books) ->
    res.json books: books

exports.addBook = (req, res) ->
  Book.find {}, (err, books) ->
    res.json books: books

exports.upload = (req, res) ->
  console.log req.files
  path = req.files.book.path
  pathParts = path.split('/')
  name = req.files.book.name
  newPath = path.replace(pathParts[pathParts.length - 1], Math.floor((Math.random()*1000)+1) + '_' + name)
  fs.rename path, newPath
  book = new Book({filepath: newPath, filename: name})
  book.save()

  # res.send(path.join(__dirname, 'files'), req.files)
  # res.json status: format("\nuploaded %s (%d Kb) to %s as %s", req.files.book.name, req.files.book.size / 1024 | 0, req.files.book.path, req.files.book.name)
  res.render "index"

