//
//  File.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import Combine
import Foundation
import SharedClientServer

protocol Api {
    associatedtype Request: Codable
    associatedtype Response: Codable
    static var url: URL { get }
    var requestBody: Request? { get }
    func request() -> AnyPublisher<Response, Error>
}

extension Api {
    func request() -> AnyPublisher<Response, Error> {
        var req = URLRequest(url: Self.url)
        req.httpBody = requestBody.flatMap { try? JSONEncoder().encode($0) }
        req.httpMethod = "POST"
        return URLSession.shared
            .dataTaskPublisher(for: req)
            .tryMap { (output: URLSession.DataTaskPublisher.Output) -> Data in
                guard let res = output.response as? HTTPURLResponse, 200 ..< 300 ~= res.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

protocol EndpointApi: Api where Request == Endpoint.Request, Response == Endpoint.Response {
    associatedtype Endpoint: EndpointInterface
    static var base: URL { get }
}

extension EndpointApi {
    static var base: URL { URL(string: "http://127.0.0.1:8080")! }
}

extension EndpointApi {
    static var url: URL {
        return base.appendingPathComponent(Endpoint.path)
    }
}

struct FileListApi: EndpointApi {
    typealias Request = FileListEndpoint.Request
    typealias Response = FileListEndpoint.Response

    typealias Endpoint = FileListEndpoint
    
    let requestBody: Request?
    init(expect: Int) {
        self.requestBody = .init(expect: expect)
    }
}
