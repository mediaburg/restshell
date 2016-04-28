AbstractProcessor = require './AbstractProcessor'

class ResponseJson extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @input = "json"
        @params =
            "json" : null

    run : () ->
        @userSession.getResponse().json(@params.json)

module.exports = ResponseJson
