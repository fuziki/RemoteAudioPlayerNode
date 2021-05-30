//
//  File.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import Combine
import Foundation
import EndpointInterface
import NIOHTTP1

protocol Api {
    associatedtype Request: Codable
    associatedtype Response: Codable
    var url: URL { get }
    var method: HTTPMethod { get }
    var requestBody: Request? { get }
    func request() -> AnyPublisher<Response, Error>
}

extension Api {
    func request() -> AnyPublisher<Response, Error> {
        var req = URLRequest(url: url)
        req.httpBody = requestBody.flatMap { try? JSONEncoder().encode($0) }
        req.httpMethod = method.rawValue
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

struct EndpointApi<Request: Codable, Response: Codable>: Api {
    let url: URL
    let method: HTTPMethod
    let requestBody: Request?
}

protocol EndpointClient {
    func request<T: EndpointInterface>(interface: T.Type, body: T.Request?) -> AnyPublisher<T.Response, Error>
}

class DefaultEndpointClient: EndpointClient {
    func request<T: EndpointInterface>(interface: T.Type, body: T.Request?) -> AnyPublisher<T.Response, Error> {
        let url = URL(string: "http://127.0.0.1:8080")!
            .appendingPathComponent(interface.path)
        return EndpointApi(url: url, method: interface.method, requestBody: body)
            .request()
    }
}
