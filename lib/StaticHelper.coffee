fs = require('fs')
globule = require('globule')

module.exports =
    url : "/"
    path : "/"

    setStaticUrl : (@url) ->
    setStaticPath : (@path) ->

    moveFileToStatic : (path, staticName) ->
        fs.renameSync(path, "#{@path}#{staticName}")
        return "#{@url}#{staticName}"

    getStaticFilePath : (staticName) ->
        return "#{@path}#{staticName}"

    getStaticUrl : (staticName) ->
        return "#{@url}#{staticName}"

    deleteByJobId : (jobId) ->
        files = globule.find("#{jobId}*", {srcBase: @path})
        for file in files
            fs.unlinkSync "#{@path}#{file}"
