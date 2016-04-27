AbstractProcessor = require './AbstractProcessor'
fs = require 'fs'

class AsyncStep extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @forceParams = true
        @successReady = false
        @erroReady = false

    run : () ->
        if @currentStep.steps?
            for name of @currentStep.steps
                step = @currentStep.steps[name]
                if step.processor?
                    processorFile = "#{__dirname}/#{step.processor}.coffee"
                    if fs.existsSync processorFile
                        processor = new (require processorFile)(@jobId)
                        processor.setUserSession @userSession
                        processor.setCurrentStep @currentStep

                        paramsPrefix = ""
                        if step.paramPrefix?
                            paramsPrefix = step.paramPrefix

                        if step.params?
                            processor.setParams(step.params, paramsPrefix)

                        processor.setParams(@params, paramsPrefix, true)

                        if @userSession
                            processor.setParams(@userSession.getRequest(), paramsPrefix)

                        if prevOutput? && typeof prevOutput is "object"
                            processor.setParams(prevOutput, paramsPrefix)

                        processor.onSuccess (currentStep, userSession, output) =>
                            if !@successReady
                                @successReady = true
                                @onSuccess(@currentStep, @userSession, output)

                        processor.onError (currentStep, userSession, output) =>
                            if !@errorReady
                                @errorReady = true
                                @onError(@currentStep, @userSession, output)

                        processor.run()


module.exports = AsyncStep
