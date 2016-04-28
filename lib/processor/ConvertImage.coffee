AbstractProcessor = require './AbstractProcessor'
File = require '../File'
exec        = require('child_process').exec

class ConvertImage extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @input = "file"
        @command = "convert"
        @params =
            "file" : null
            "resize" : null

    run : () ->
        command = @command

        inputFile = ""
        convertParams = ""
        for name of @params
            if @params[name] != null
                value = @params[name]

                if typeof value is "object"
                    filename = "#{@jobId}-#{name}.jpg"
                    value.makeStatic filename
                    value = value.getPath()

                switch name
                    when "file" then inputFile = value
                    else convertParams += " -#{name} '#{value}'"

        output = new File()
        output.greateStatic("#{@jobId}.jpg", "jpg")

        command += " #{inputFile}#{convertParams} #{output.getPath()}"

        jobExec = exec(command)
        jobExec.stderr.on 'data', (data) =>
            @cb.onError(data)

        jobExec.stderr.on 'end', () =>
            @cb.onSuccess(output)


module.exports = ConvertImage
