#!/usr/bin/env coffee

yargs = require 'yargs'
uuid = require 'uuid'

HTTPServer = require './lib/HTTPServer'

Recipe = require './lib/Recipe'
StaticHelper = require './lib/StaticHelper'
UserSession = require './lib/UserSession'

yargs = yargs.options({
    'recipe' :
        type: 'string'
        demand: true
    }).argv


recipeConfig = require "./recipe/#{yargs.recipe}"

StaticHelper.setStaticUrl("http://localhost:3000/static/")
StaticHelper.setStaticPath("#{__dirname}/static/")

restOptions =
    onStart : (req, res) ->
        jobId = uuid.v4()

        session = new UserSession(req, res)

        recipe = new Recipe(recipeConfig, jobId)
        recipe.setUserSession(session)
        recipe.run()

        if !recipe.hasResponse()
            res.json("jobId":jobId)

app = new HTTPServer(restOptions)
app.listen()
