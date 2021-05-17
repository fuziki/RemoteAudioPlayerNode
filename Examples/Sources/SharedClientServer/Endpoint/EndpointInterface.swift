//
//  EndpointInterface.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import Foundation

public enum HttpMethod: String {
    case post = "POST"
}

public protocol EndpointInterface {
    associatedtype Request: Codable
    associatedtype Response: Codable
    static var path: String { get }
    static var method: HttpMethod { get }
}

public struct FileListEndpoint: EndpointInterface {
    public struct Request: Codable {
        public let expect: Int
        public init(expect: Int) {
            self.expect = expect
        }
    }
    public struct Response: Codable {
        public let fileList: [String]
        public init(fileList: [String]) {
            self.fileList = fileList
        }
    }
    public static var path: String = "file_lsit"
    public static var method: HttpMethod = .post
}
