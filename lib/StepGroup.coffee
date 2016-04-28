extend = require 'node.extend'

class StepGroup
    constructor : (@name, config) ->
        @steps = {}
        @stepsInput = null
        @config =
            async : true

        @config = extend(true, {}, @config, config)

        @cb =
            stepRunner : null


    setSteps : (@steps) ->

    setStepRunner : (cb) ->
        @cb.stepRunner = cb

    run : (stepInput) ->
        if @config.async
            for name of @steps
                step = @steps[name]
                step.setStepRunner (stepInput, name) =>
                    if name != null
                        if !@steps[name]? && @cb.stepRunner
                            @cb.stepRunner(stepInput, name)
                        else
                            @steps[name].run(stepInput)
                step.run(stepInput)
        else
            console.log "Sync Worker not implemented!"







module.exports = StepGroup
