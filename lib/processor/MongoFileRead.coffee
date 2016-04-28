AbstractProcessor = require './AbstractProcessor'
File = require '../File'
fs = require 'fs'

mongo        = require 'mongodb'
MongoClient  = mongo.MongoClient
Grid         = require 'gridfs-stream'

class MongoFileRead extends AbstractProcessor
    constructor : (@jobId) ->
        super
        @params =
            "url" : null
            "collection" : null
            "fileId" : null
            "filePosix" : "mongo.file"
            "onFilter" : (params, userSession) =>
                root: params.collection
                _id: params.fileId

    run : () ->
        MongoClient.connect @params.url, (err, db) =>
            gfs = Grid(db, mongo)

            gfs.findOne @params.onFilter(@params, @userSession), (err, file) =>
                if file
                    readRequest =
                        root : @params.collection
                        _id : file._id

                    readstream = gfs.createReadStream(readRequest)

                    output = new File()
                    output.greateStatic("#{@jobId}.#{@params.filePosix}")

                    writable = fs.createWriteStream(output.getPath());
                    readstream.pipe(writable)

                    writable.on 'close', (file) =>
                        db.close()

                        @cb.onSuccess(output)
                else
                    error =
                        state : "error"
                        message : "File not Found"
                        fileId : @params.fileId
                        jobId : @jobId

                    @cb.onError(error)




module.exports = MongoFileRead
