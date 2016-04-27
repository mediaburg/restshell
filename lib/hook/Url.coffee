AbstractHook = require "./AbstractHook"

class UrlHook extends AbstractHook
    constructor : () ->
        super
        @params =
            url : ""
            queryParams : {}
            type : "get"


module.exports = UrlHook
