AbstractProcessor = require './AbstractProcessor'
File = require '../File'
exec        = require('child_process').exec

class HTML2PDF extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @command = "wkhtmltopdf"
        @params =
            "content-html" : null
            "header-html" : null
            "footer-html" : null
            "page-size" : "A4"
            "orientation" : "portrait"
            "header-spacing" : null
            "footer-spacing" : null
            "encoding" : "utf8"

    run : () ->
        command = @command

        content = ""
        for name of @params
            if @params[name] != null
                value = @params[name]

                if typeof value is "object"
                    if value.type is "text/html"
                        filename = "#{@jobId}-#{name}.html"
                        value.makeStatic filename

                        value = value.staticUrl

                switch name
                    when "content-html" then content = value
                    else command += " --#{name} #{value}"

        output = new File()
        output.greateStatic("#{@jobId}.pdf", "pdf")

        command += " #{content} #{output.getPath()}"

        console.log command

        jobExec = exec(command)
        #hook.onStart(@jobId)
        jobExec.stderr.on 'data', (data) =>
            #console.log "" + data
            if (match = data.match(/\s\((\d+)\/(\d+)\)/g))
                state = RegExp.$1 - 1
                if state > 0
                    state = (100 / 6) * state
                    #hook.onProcess @jobId, state
            else if(data.match(/Done/))
                console.log output
                @cb.onSuccess(output)


module.exports = HTML2PDF
