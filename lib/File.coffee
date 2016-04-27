StaticHelper = require './StaticHelper'

class File
    constructor : () ->
        @path = ""
        @filename = ""
        @type = ""
        @isStatic = false
        @staticUrl = ""

    greateStatic : (name, type) ->
        @isStatic = true
        @filename = name
        @path = StaticHelper.getStaticFilePath(name)
        @staticUrl = StaticHelper.getStaticUrl name
        @type = type

    makeStatic : (staticName) ->
        if !@isStatic
            @name = staticName
            @isStatic = true
            @staticUrl = StaticHelper.moveFileToStatic @path, staticName
            @path = StaticHelper.getStaticFilePath staticName

    setByHttpRequest : (httpFile) ->
        @path = httpFile.path
        @type = httpFile.type
        @name = httpFile.name

    getPath : () ->
        @path

    getName : () ->
        @name


module.exports = File
