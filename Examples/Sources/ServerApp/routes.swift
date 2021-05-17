import SharedClientServer
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.on(endpoint: FileListEndpoint.self) { (req: FileListEndpoint.Request) -> FileListEndpoint.Response in
        let fileList: [String] = (0..<req.expect).map { _ in UUID().uuidString }
        return FileListEndpoint.Response(fileList: fileList)
    }
    
}
