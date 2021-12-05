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
                .tryExtractData(decoder: decoder)
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
        let data = try handleDataResponse(decoder: decoder, data: dataResponse.0, response: dataResponse.1)
        return try decoder.decode(Weather.self, from: data)
    }
}

// MARK: Private

/// An error thrown when problems occur with one of the APIs.
private struct StormGlassNetworkError: CustomNSError, Decodable {
    public static let errorDomain: String = "StormGlassKit.StormGlassNetworkError"
    
    static var noResponse: Self {
        Self(status: 204, statusMessage: "Bad Response", message: "The API response was empty.")
    }
    
    static func invalidStatus(_ status: Int) -> Self {
        Self(status: status, statusMessage: "Bad Response", message: "The status code recieved from the API was not valid.")
    }
    
    static func invalidRequest(_ description: String) -> Self {
        Self(status: 400, statusMessage: "Invalid Request", message: "\(description) was not a valid URL request.")
    }
    
    public let status: Int
    public let statusMessage: String
    public let message: String
            
    public var errorUserInfo: [String: Any] {
        return ["status": status, "statusMessage": statusMessage, "message": message]
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
        guard let url = components.url else { throw StormGlassNetworkError.invalidRequest(components.description) }
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
    func tryExtractData<Coder>(decoder: Coder) -> Publishers.TryMap<URLSession.DataTaskPublisher, Data> where Coder: TopLevelDecoder, Coder.Input == Data {
        return tryMap({ (data: Data, response: URLResponse) -> Data in
            try handleDataResponse(decoder: decoder, data: data, response: response)
        })
    }
}

private func handleDataResponse<Coder>(decoder: Coder, data: Data, response: URLResponse) throws -> Data where Coder: TopLevelDecoder, Coder.Input == Data {
    guard let response = response as? HTTPURLResponse else {
        throw StormGlassNetworkError.noResponse
    }
    guard response.statusCode == 200 else {
        throw StormGlassNetworkError.invalidStatus(response.statusCode)
    }
    if let underlyingError = try? decoder.decode(StormGlassNetworkError.self, from: data) {
        throw underlyingError
    }
    return data
}
