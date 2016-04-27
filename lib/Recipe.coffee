fs = require 'fs'

class Recipe
    constructor : (@config, @jobId) ->
        @currentStep = null
        @userSession = null

    setUpMainStep : ->
        if @config.mainStep?
            return @setUpCurrentStep @config.mainStep

    setUpCurrentStep : (stepName) ->
        if @config.steps?[stepName]?
            @currentStep = @config.steps[stepName]
        else
            @currentStep = {}

    setUserSession : (@userSession) ->

    hasResponse : ->
        if @config.response?
            return @config.response

        return false

    run : (prevOutput) ->
        if @currentStep is null
            @setUpMainStep()

        if @currentStep.processor?
            processorFile = "#{__dirname}/processor/#{@currentStep.processor}.coffee"
            if fs.existsSync processorFile
                paramsPrefix = ""
                if @currentStep.paramPrefix?
                    paramsPrefix = @currentStep.paramPrefix

                processor = new (require processorFile)(@jobId)
                processor.setUserSession @userSession
                processor.setCurrentStep @currentStep

                if @currentStep.params?
                    processor.setParams(@currentStep.params, paramsPrefix)

                if @userSession
                    processor.setParams(@userSession.getRequest(), paramsPrefix)

                if prevOutput? && typeof prevOutput is "object"
                    processor.setParams(prevOutput, paramsPrefix)

                processor.onSuccess (currentStep, userSession, output) =>
                    if currentStep.success?.step?
                        @setUpCurrentStep(currentStep.success.step)

                        if currentStep.success.prevOutput?
                            out = {}
                            out[currentStep.success.prevOutput] = output
                            @run(out)
                        else
                            @run(output)

                processor.onError (currentStep, userSession, output) =>
                    if currentStep.error?.step?
                        @setUpCurrentStep(currentStep.error.step)

                        if currentStep.error.prevOutput?
                            out = {}
                            out[currentStep.error.prevOutput] = output
                            @run(out)
                        else
                            @run(output)

                processor.run()
            else
                console.log "No Processor found: #{@currentStep.processor}"

module.exports = Recipe
