import EndpointInterface
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.on(endpoint: FileListEndpoint.self) { (req: FileListEndpoint.Request) in
        let fileList: [String] = db().fileList.prefix(req.expect).map { $0 }
        return FileListEndpoint.Response(fileList: fileList)
    }
    
}
