//
//  Application+Extension.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import SharedClientServer
import Vapor

extension Application {
    public func on<T: EndpointInterface>(endpoint: T.Type, use closure: @escaping ((T.Request) -> T.Response)) {
        self.on(.POST, PathComponent(stringLiteral: T.path)) { (req: Request) -> ClientResponse in
            let content = try req.content.decode(T.Request.self, using: JSONDecoder())
            let res = closure(content)
            let data = try JSONEncoder().encode(res)
            let str = String(data: data, encoding: .utf8) ?? ""
            return ClientResponse(body: .init(string: str))
        }
    }
}
