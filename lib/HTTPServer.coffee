express = require 'express'
bodyParser = require 'body-parser'
multipart = require 'connect-multiparty'
extend = require 'node.extend'

class HTTPServer
    constructor : (options) ->
        @options =
            port : 3000
            staticFilesPath : "#{__dirname}/../static/"
            staticFilesUrl : "/static/"
            onStart : (req, res) ->

        @options = extend(true, @options, options)
        @app = express()
        @multipartMiddleware = multipart()

        @app.use(@options.staticFilesUrl, express.static(@options.staticFilesPath))
        @app.use('/', express.static('public'))

        @app.all '/start', @multipartMiddleware, @options.onStart.bind(@)

    listen : () ->
        @app.listen @options.port, () =>
            console.log("RestShell listening on port #{@options.port}!")

module.exports = HTTPServer
