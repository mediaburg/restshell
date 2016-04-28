module.exports =
    main : "writeToMongo"
    response : true
    steps :
        serveJson:
            processor : "ResponseJson"

        writeToMongo :
            processor : "MongoFileWrite"
            params :
                url : "mongodb://192.168.100.31:27017/sfc"
                collection : "images"
            success :
                step : "serveJson"
            error :
                step : "serveJson"
