//
//  Request.swift
//  WeatherApp
//
//  Created by Олег Романов on 24.03.2024.
//

import Foundation

public struct Request<Response>: @unchecked Sendable {
    public var method: HTTPMethod
    public var url: URL?
    public var query: [(String, String?)]?
    public var body: Encodable?
    public var headers: [String: String]?
    
    public init(
        url: URL,
        method: HTTPMethod = .get,
        query: [(String, String?)]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) {
        self.method = method
        self.url = url
        self.query = query
        self.headers = headers
        self.body = body
    }
    
    public init(
            path: String,
            method: HTTPMethod = .get,
            query: [(String, String?)]? = nil,
            body: Encodable? = nil,
            headers: [String: String]? = nil
        ) {
            self.method = method
            self.url = URL(string: path.isEmpty ? "/" : path)
            self.query = query
            self.headers = headers
            self.body = body
        }
}

public struct HTTPMethod: RawRepresentable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public static let get: HTTPMethod = "GET"
    public static let post: HTTPMethod = "POST"
    public static let put: HTTPMethod = "PUT"
    public static let delete: HTTPMethod = "DELETE"
}
