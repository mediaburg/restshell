AbstractProcessor = require './AbstractProcessor'

class ResponseFile extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @input = "file"
        @params =
            "file" : null

    run : () ->
        @userSession.getResponse().sendFile(@params.file.getPath())

module.exports = ResponseFile
