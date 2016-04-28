module.exports =
    main : "loadResizedImage"
    response : true
    steps :
        loadResizedImage :
            processor : "MongoFileRead"
            params :
                url : "mongodb://192.168.100.31:27017/sfc"
                collection : "images_resize"
                filePosix : "read.jpg"
                onFilter : (params, userSession) ->
                    root : params.collection
                    "metadata.parent" : params.fileId
                    "metadata.size" : userSession.getRequest().resize

            error :
                step : "loadOriginalImage"

            success :
                step : "serveImage"

        serveImage :
            processor : "ResponseFile"

        serveError :
            processor : "ResponseJson"

        loadOriginalImage :
            processor : "MongoFileRead"
            params :
                url : "mongodb://192.168.100.31:27017/sfc"
                collection : "images"
                filePosix : "read.jpg"
                onFilter : (params, userSession) ->
                    root: params.collection
                    _id: params.fileId
            error :
                step : "serveError"

            success :
                step : "resizeOriginalImage"


        resizeOriginalImage :
            processor : "ConvertImage"
            success :
                step : "serveAndSave"

            error :
                step : "serveError"


        serveAndSave:
            async : true
            steps :
                serveImage :
                    processor : "ResponseFile"

                writeToMongo :
                    processor : "MongoFileWrite"
                    params :
                        url : "mongodb://192.168.100.31:27017/sfc"
                        collection : "images_resize"
                        onWriteData : (params, userSession) =>
                            filename    : params.file.getName()
                            root        : params.collection
                            metadata :
                                parent : userSession.getRequest()["fileId"]
                                size : userSession.getRequest().resize


    "hook" : [
        {
            "name" : "UrlHook",
            params :
                url : "http://localhost:3005/"
                queryParams :
                    "auth-token": "blabla"
        }
        {
            "name" : "UrlHook",
            params :
                url : "http://localhost:3005/"
                queryParams :
                    "auth-token": "blabla"
        }
    ]
