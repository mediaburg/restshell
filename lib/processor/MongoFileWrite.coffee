AbstractProcessor = require './AbstractProcessor'
File = require '../File'
fs = require 'fs'

mongo        = require 'mongodb'
MongoClient  = mongo.MongoClient
Grid         = require 'gridfs-stream'

class MongoFileWrite extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @input = "file"
        @params =
            "url" : null
            "collection" : null
            "file" : null
            "onWriteData" : (params, userSession) =>
                filename    : params.file.getName()
                root        : params.collection

    run : () ->
        if !@params.file?
            error =
                state : "error"
                message : "No File provided"
                jobId : @jobId

            @cb.onError error
        else
            MongoClient.connect @params.url, (err, db) =>
                gfs = Grid(db, mongo)

                writestream = gfs.createWriteStream @params.onWriteData(@params, @userSession)

                writestream.on 'close', (metadata) =>
                    db.close()
                    @cb.onSuccess(metadata)

                fs.createReadStream(@params.file.getPath()).pipe(writestream)

module.exports = MongoFileWrite
