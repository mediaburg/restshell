uuid = require 'uuid'
extend = require 'node.extend'

class AbstractProcessor
    constructor : (@jobId) ->
        @params = {}
        @forceParams = false
        @command = ""
        @userSession = null
        @currentStep = null

        @cb =
            onSuccess : (currentStep, userSession, output) ->
            onError : (currentStep, userSession, output) ->
                console.log output

    run : () ->
        @cb.onSuccess(@currentStep, @userSession, uuid.v4())

    setUserSession : (@userSession) ->

    setCurrentStep : (@currentStep) ->

    setParams : (params, prefix, tryBothNames) ->
        loopParams = @params

        if @forceParams
            loopParams = extend(true, loopParams, params)

        for name of @params
            prefixName = name
            if prefix
                prefixName = "#{prefix}-#{name}"

            if params[prefixName]?
                @params[name] = params[prefixName]
            else if tryBothNames && params[name]
                @params[name] = params[name]

    onSuccess : (cb) ->
        @cb.onSuccess = cb

    onError : (cb) ->
        @cb.onError = cb

module.exports = AbstractProcessor
