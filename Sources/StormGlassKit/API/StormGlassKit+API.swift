//
//  StormGlassKit+API.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import CoreLocation
import Combine

public extension StormGlassKit {
    static func fetchWeather(coordinate: CLLocationCoordinate2D, parameters: Set<WeatherQueryParameter>,
                             start: Date?, end: Date?, sources: Set<WeatherDataSource>?,
                             session: URLSession = .shared) -> AnyPublisher<Weather, Error> {
        fetchWeather(coordinate: coordinate, parameters: parameters,
                     start: start, end: end, sources: sources,
                     session: session, decoder: JSONDecoder())
    }
    
    static func fetchWeather<Coder>(coordinate: CLLocationCoordinate2D, parameters: Set<WeatherQueryParameter>,
                                    start: Date?, end: Date?, sources: Set<WeatherDataSource>?,
                                    session: URLSession = .shared, decoder: Coder) -> AnyPublisher<Weather, Error> where Coder: TopLevelDecoder, Coder.Input == Data {
        do {
            let request = try weatherURLRequest(coordinate: coordinate, parameters: parameters, start: start, end: end, sources: sources)
            return session.dataTaskPublisher(for: request)
                .tryExtractData(decoder: decoder, request: request)
                .decode(type: Weather.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

@available(iOS 15.0, *)
public extension StormGlassKit {
    static func fetchWeather(coordinate: CLLocationCoordinate2D, parameters: Set<WeatherQueryParameter>,
                             start: Date?, end: Date?, sources: Set<WeatherDataSource>?,
                             session: URLSession = .shared) async throws -> Weather {
        try await fetchWeather(coordinate: coordinate, parameters: parameters,
                               start: start, end: end, sources: sources,
                               session: session, decoder: JSONDecoder())
    }
    
    static func fetchWeather<Coder>(coordinate: CLLocationCoordinate2D, parameters: Set<WeatherQueryParameter>,
                                    start: Date?, end: Date?, sources: Set<WeatherDataSource>?,
                                    session: URLSession = .shared, decoder: Coder) async throws -> Weather where Coder: TopLevelDecoder, Coder.Input == Data {
        let request = try weatherURLRequest(coordinate: coordinate, parameters: parameters, start: start, end: end, sources: sources)
        let dataResponse = try await session.data(for: request)
        let data = try handleDataResponse(decoder: decoder, data: dataResponse.0, response: dataResponse.1, request: request)
        return try decoder.decode(Weather.self, from: data)
    }
}

// MARK: Private

/// An error thrown when problems occur with one of the APIs.
private struct StormGlassNetworkError: CustomNSError {
    public static let errorDomain: String = "StormGlassKit.StormGlassNetworkError"
    
    static func noResponse(for request: URLRequest) -> Self {
        Self(status: 204, statusMessage: "Bad Response", message: "The API response was empty.", request: request)
    }
    
    static func invalidStatus(_ status: Int, request: URLRequest) -> Self {
        Self(status: status, statusMessage: "Bad Response", message: "The status code recieved from the API was not valid.", request: request)
    }
    
    static func invalidRequest(reason: String) -> Self {
        Self(status: 400, statusMessage: "Invalid Request", message: "The request was not valid for reason: \(reason)", request: nil)
    }
    
    public let status: Int
    public let statusMessage: String
    public let message: String
    public var request: URLRequest?
            
    public var errorUserInfo: [String: Any] {
        var info: [String: Any] = ["status": status, "statusMessage": statusMessage, "message": message]
        if let request = request {
            info["request"] = request
        }
        return info
    }
}

extension StormGlassNetworkError: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errors = try container.decode([String: String].self, forKey: .errors)
        self = .invalidRequest(reason: "Errors: \(errors)")
    }
    
    private enum CodingKeys: String, CodingKey {
        case errors
    }
}

internal extension StormGlassKit {
    static func urlComponents(apiEndpoint: String, queryItems: [URLQueryItem]) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.stormglass.io"
        components.path = "/v2/\(apiEndpoint)"
        components.queryItems = queryItems
        return components
    }
    
    static func weatherURLRequest(coordinate: CLLocationCoordinate2D, parameters: Set<WeatherQueryParameter>,
                           start: Date?, end: Date?, sources: Set<WeatherDataSource>?) throws -> URLRequest {
        assert(!parameters.isEmpty, "API expects at least one parameter")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: coordinate.latitude),
            URLQueryItem(name: "lng", value: coordinate.longitude),
            URLQueryItem(name: "params", value: parameters.map(\.rawValue).joined(separator: ",")),
        ]
        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: start.timeIntervalSince1970))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: end.timeIntervalSince1970))
        }
        if let sources = sources, !sources.isEmpty {
            queryItems.append(URLQueryItem(name: "source", value: sources.map(\.rawValue).joined(separator: ",")))
        }
        let components = urlComponents(apiEndpoint: "weather/point", queryItems: queryItems)
        guard let url = components.url else { throw StormGlassNetworkError.invalidRequest(reason: "Invalid URL components: \(components.description)") }
        var request: URLRequest = URLRequest(url: url)
        request.setValue(configuration.apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
}

private extension URLQueryItem {
    init(name: String, value: Double) {
        self.init(name: name, value: String(value))
    }
}

private extension URLSession.DataTaskPublisher {
    func tryExtractData<Coder>(decoder: Coder, request: URLRequest) -> Publishers.TryMap<URLSession.DataTaskPublisher, Data> where Coder: TopLevelDecoder, Coder.Input == Data {
        return tryMap({ (data: Data, response: URLResponse) -> Data in
            try handleDataResponse(decoder: decoder, data: data, response: response, request: request)
        })
    }
}

private func handleDataResponse<Coder>(decoder: Coder, data: Data, response: URLResponse, request: URLRequest) throws -> Data where Coder: TopLevelDecoder, Coder.Input == Data {
    guard let response = response as? HTTPURLResponse else {
        throw StormGlassNetworkError.noResponse(for: request)
    }
    guard response.statusCode == 200 else {
        throw StormGlassNetworkError.invalidStatus(response.statusCode, request: request)
    }
    if let underlyingError = try? decoder.decode(StormGlassNetworkError.self, from: data) {
        throw underlyingError
    }
    return data
}
