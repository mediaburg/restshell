fs = require 'fs'
extend = require 'node.extend'

class Step
    constructor : (@name, config, @jobId) ->
        @config =
            processor : null
            success : null
            error : null
            params : {}

        @config = extend(true, {}, @config, config)

        @paramPrefix = ""

        @cb =
            stepRunner : null

    setUserSession : (@userSession) ->

    setPrefix : (@paramPrefix) ->

    run : (stepInput) ->
        if @config.processor?
            processorFile = "#{__dirname}/processor/#{@config.processor}.coffee"
            if fs.existsSync processorFile
                processor = new (require processorFile)(@jobId)
                processor.setUserSession @userSession
                processor.setInput stepInput
                processor.setParams @config.params

                if @userSession
                    processor.setParams(@userSession.getRequest())
                    processor.setParams(@userSession.getRequest(), @paramPrefix)

                processor.onSuccess (output) =>
                    @onSuccess(output)
                processor.onError (output) =>
                    @onError(output)

                processor.run()

    setStepRunner : (cb) ->
        @cb.stepRunner = cb

    onSuccess : (output) ->
        if @cb.stepRunner
            if @config.success?.step
                @cb.stepRunner(output, @config.success.step)
            else
                @cb.stepRunner(output, null)

    onError : (output) ->
        if @cb.stepRunner
            if @config.error?.step
                @cb.stepRunner(output, @config.error.step)
            else
                @cb.stepRunner(output, null)





module.exports = Step
