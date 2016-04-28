fs = require 'fs'
Step = require './Step'
StepGroup = require './StepGroup'

class Recipe
    constructor : (@config, @jobId) ->
        @currentStep = null
        @userSession = null
        @steps = null

    setUserSession : (@userSession) ->

    hasResponse : ->
        if @config.response?
            return @config.response

        return false

    setSteps : (@steps) ->

    run : ->
        if @steps is null && @config.steps
            @setSteps @initSteps(@config.steps)

        if @config.main?
            @runStep(null, @config.main)

    runStep : (stepInput, name) ->
        if name != null
            @steps[name].run(stepInput)

    initSteps : (steps, prefix) ->
        r = {}
        for name of steps
            stepConfig = steps[name]
            if stepConfig.steps?
                group = new StepGroup(name, stepConfig)
                group.setStepRunner (stepInput, name) =>
                    @runStep(stepInput, name)

                if stepConfig.steps?
                    group.setSteps(@initSteps(stepConfig.steps, name))

                r[name] = group
            else
                r[name] = @createStep(name, stepConfig, prefix)
        r

    createStep : (name, config, prefix) ->
        step = new Step(name, config, @jobId)
        step.setUserSession @userSession
        if prefix?
            step.setPrefix "#{prefix}-#{name}-"
        else
            step.setPrefix "#{name}-"
        step.setStepRunner (stepInput, nextStep) =>
            @runStep(stepInput, nextStep)

        return step




    ###
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
        ###

module.exports = Recipe
