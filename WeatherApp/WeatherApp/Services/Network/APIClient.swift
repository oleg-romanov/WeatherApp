//
//  APIClient.swift
//  WeatherApp
//
//  Created by Олег Романов on 24.03.2024.
//

import Foundation

public actor APIClient {
    
    public nonisolated let configuration: Configuration
    
    public nonisolated let session: URLSession

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public struct Configuration: @unchecked Sendable {
        public var baseURL: URL?
        public var sessionConfiguration: URLSessionConfiguration = .default
        public var sessionDelegate: URLSessionDelegate?
        public var decoder: JSONDecoder
        public var encoder: JSONEncoder

        public init(
            baseURL: URL?,
            sessionConfiguration: URLSessionConfiguration = .default
        ) {
            self.baseURL = baseURL
            self.sessionConfiguration = sessionConfiguration
            self.decoder = JSONDecoder()
            self.decoder.dateDecodingStrategy = .iso8601
            self.encoder = JSONEncoder()
            self.encoder.dateEncodingStrategy = .iso8601
        }
    }
    
    public init(baseURL: URL?, _ configure: @Sendable (inout APIClient.Configuration) -> Void = { _ in }) {
        var configuration = Configuration(baseURL: baseURL)
        configure(&configuration)
        self.init(configuration: configuration)
    }
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.sessionConfiguration)
        self.decoder = configuration.decoder
        self.encoder = configuration.encoder
    }
    
    @discardableResult public func send<T: Decodable>(
        _ request: Request<T>,
        delegate: URLSessionDataDelegate? = nil,
        configure: ((inout URLRequest) throws -> Void)? = nil
    ) async throws -> Response<T> {
        let response = try await data(for: request, delegate: delegate, configure: configure)
        let value: T = try await decode(response.data, using: decoder)
        return response.map { _ in value }
    }
    
    public func data<T>(
            for request: Request<T>,
            delegate: URLSessionDataDelegate? = nil,
            configure: ((inout URLRequest) throws -> Void)? = nil
        ) async throws -> Response<Data> {
            let request = try await makeURLRequest(for: request, configure)
            
            let (data, response) = try await session.data(for: request)
            try validate(response)
            
            return Response(value: data, data: data, response: response)
    }
    
    private func makeURLRequest<T>(
        for request: Request<T>,
        _ configure: ((inout URLRequest) throws -> Void)?
    ) async throws -> URLRequest {
        let url = try makeURL(for: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpMethod = request.method.rawValue
        if let body = request.body {
            urlRequest.httpBody = try await encode(body, using: encoder)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil &&
                session.configuration.httpAdditionalHeaders?["Content-Type"] == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        if urlRequest.value(forHTTPHeaderField: "Accept") == nil &&
            session.configuration.httpAdditionalHeaders?["Accept"] == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        if let configure = configure {
            try configure(&urlRequest)
        }
        return urlRequest
    }
    
    private func makeURL<T>(for request: Request<T>) throws -> URL {
        func makeURL() -> URL? {
            guard let url = request.url else {
                return nil
            }
            return url.scheme == nil ? configuration.baseURL?.appendingPathComponent(url.absoluteString) : url
        }
        
        guard let url = makeURL(), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        if let query = request.query, !query.isEmpty {
            components.queryItems = query.map(URLQueryItem.init)
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
    
    // MARK: Helpers

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.incorrectResponse
        }
        
        switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                throw APIError.invalidAPIKey
            case 404:
                throw APIError.badRequest
            case 429:
                throw APIError.tooManyRequests
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.unacceptableStatusCode(httpResponse.statusCode)
        }
    }
    
    func decode<T: Decodable>(_ data: Data, using decoder: JSONDecoder) async throws -> T {
        if T.self == Data.self {
            return data as! T
        } else if T.self == String.self {
            guard let string = String(data: data, encoding: .utf8) else {
                throw URLError(.badServerResponse)
            }
            return string as! T
        } else {
            return try await Task.detached {
                try decoder.decode(T.self, from: data)
            }.value
        }
    }
    
    func encode(_ value: Encodable, using encoder: JSONEncoder) async throws -> Data? {
        if let data = value as? Data {
            return data
        } else if let string = value as? String {
            return string.data(using: .utf8)
        } else {
            return try await Task.detached {
                try encoder.encode(value)
            }.value
        }
    }
}

public enum APIError: Error, LocalizedError {
    case unacceptableStatusCode(Int)
    case incorrectResponse
    case invalidAPIKey
    case badRequest
    case tooManyRequests
    case serverError

    public var errorDescription: String? {
        switch self {
            case .unacceptableStatusCode(let statusCode):
                return "Неожиданный статусный код ответа сервера: \(statusCode)."
            case .incorrectResponse:
                return "Некорректный ответ сервера."
            case .invalidAPIKey:
                return "Неверный API ключ."
            case .badRequest:
                return "Ошибка запроса."
            case .tooManyRequests:
                return "Слишком много запросов."
            case .serverError:
                return "Внутренняя ошибка сервера."
        }
    }
}
