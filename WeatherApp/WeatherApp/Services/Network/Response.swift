//
//  Response.swift
//  WeatherApp
//
//  Created by Олег Романов on 24.03.2024.
//

import Foundation

public struct Response<T> {
    public let value: T
    public let response: URLResponse
    public var statusCode: Int? { (response as? HTTPURLResponse)?.statusCode }
    public let data: Data
    
    public init(value: T, data: Data, response: URLResponse) {
        self.value = value
        self.data = data
        self.response = response
    }
    
    public func map<E>(_ closure: (T) throws -> E) rethrows -> Response<E> {
        Response<E>(value: try closure(value), data: data, response: response)
    }
}
