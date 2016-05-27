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
        
module.exports = Recipe
