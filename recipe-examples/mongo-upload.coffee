module.exports =
    main : "writeToMongo"
    response : true
    steps :
        writeToMongo :
            processor : "MongoFileWrite"
            params :
                url : "mongodb://mongodb:27017/collectionName"
                collection : "images"
            success :
                step : "serveJson"
            error :
                step : "serveJson"

        serveJson:
            processor : "ResponseJson"
