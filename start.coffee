#!/usr/bin/env coffee
yargs = require 'yargs'
HTTPServer = require './lib/HTTPServer'
StaticHelper = require './lib/StaticHelper'

yargs = yargs.options({
    'recipe' :
        type: 'string'
        demand: true
    }).argv

StaticHelper.setStaticUrl("http://localhost:3000/static/")
StaticHelper.setStaticPath("#{__dirname}/static/")

if typeof yargs.recipe is "string"
    yargs.recipe = [yargs.recipe]

app = new HTTPServer()

for recipe in yargs.recipe
    app.addRecipe recipe, require "./recipe/#{recipe}"

app.listen()
