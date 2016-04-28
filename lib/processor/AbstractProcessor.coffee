uuid = require 'uuid'
extend = require 'node.extend'

class AbstractProcessor
    constructor : (@jobId) ->
        @input = null
        @params = {}
        @forceParams = false
        @command = ""
        @userSession = null
        @currentStep = null

        @cb =
            stepRunner : (output) ->
            onError : (output) ->
                console.log "Error: ", output

    setInput : (input) ->
        if @input of @params
            @params[@input] = input

    run : () ->
        @cb.onSuccess(@currentStep, @userSession, uuid.v4())

    setUserSession : (@userSession) ->

    setCurrentStep : (@currentStep) ->

    setParams : (params, prefix) ->
        for name of @params
            prefixName = name
            if prefix?
                prefixName = "#{prefix}#{name}"

            if prefixName of params
                @params[name] = params[prefixName]

    onSuccess : (cb) ->
        @cb.onSuccess = cb

    onError : (cb) ->
        @cb.onError = cb

module.exports = AbstractProcessor
