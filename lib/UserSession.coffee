File = require './File'
extend = require 'node.extend'

class UserSession
    constructor : (request, @response) ->
        requestParams = extend(true, {}, request.query, request.body, request.files)

        @request = {}
        for name of requestParams
            value = requestParams[name]
            if typeof value == "object"
                curFile = new File()
                curFile.setByHttpRequest value
                value = curFile

            @request[name] = value

    getRequest : ->
        @request

    getResponse : ->
        @response


module.exports = UserSession
