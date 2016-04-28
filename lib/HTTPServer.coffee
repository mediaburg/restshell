express = require 'express'
bodyParser = require 'body-parser'
multipart = require 'connect-multiparty'
extend = require 'node.extend'
uuid = require 'uuid'
UserSession = require './UserSession'
Recipe = require './Recipe'

class HTTPServer
    constructor : (options) ->
        @options =
            port : 3000
            staticFilesPath : "#{__dirname}/../static/"
            staticFilesUrl : "/static/"

        if options?
            @options = extend(true, @options, options)

        @app = express()
        @multipartMiddleware = multipart()

        @app.use(@options.staticFilesUrl, express.static(@options.staticFilesPath))
        @app.use('/', express.static('public'))

    listen : () ->
        @app.listen @options.port, () =>
            console.log("RestShell listening on port #{@options.port}!")

    addRecipe : (name, recipeConfig) ->
        @app.all "/#{name}", @multipartMiddleware, (req, res) =>
            jobId = uuid.v4()

            session = new UserSession(req, res)

            recipe = new Recipe(recipeConfig, jobId)
            recipe.setUserSession(session)
            recipe.run()

            if !recipe.hasResponse()
                res.json("jobId":jobId)

module.exports = HTTPServer
