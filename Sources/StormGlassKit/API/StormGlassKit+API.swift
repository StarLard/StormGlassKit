//
//  StormGlassKit+API.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import CoreLocation

public extension StormGlassKit {
    static func fetchWeather(
        coordinate: CLLocationCoordinate2D,
        measurements: Set<WeatherMeasurementName>,
        start: Date?,
        end: Date?,
        sources: Set<WeatherDataSource>?,
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared
    ) async throws -> Weather {
        let apiKey = await configuration.apiKey
        let request = try weatherURLRequest(
            apiKey: apiKey,
            coordinate: coordinate,
            parameters: measurements.map(\.rawValue),
            start: start,
            end: end,
            sources: sources
        )
        let (data, response) = try await session.data(for: request)
        try validateNetworkResponse(
            decoder: decoder,
            data: data,
            response: response,
            request: request
        )
        return try decoder.decode(Weather.self, from: data)
    }
}

// MARK: Private

/// An error thrown when problems occur with one of the APIs.
public struct StormGlassKitNetworkError: CustomNSError {
    public static let errorDomain: String = "StormGlassKit.StormGlassNetworkError"

    static func noResponse(for request: URLRequest) -> Self {
        Self(status: 204, statusMessage: "Bad Response", message: "The API response was empty.", request: request)
    }

    static func invalidStatus(_ status: Int, request: URLRequest) -> Self {
        Self(status: status, statusMessage: "Bad Response", message: "The status code recieved from the API was not valid.", request: request)
    }

    static func invalidRequest(reason: String) -> Self {
        Self(status: 400, statusMessage: "Invalid Request", message: "The request was not valid for reason: \(reason)")
    }

    public let status: Int
    public let statusMessage: String
    public let message: String
    public var request: URLRequest?
    public var underlyingError: Error?

    public var errorUserInfo: [String: Any] {
        var info: [String: Any] = ["status": status, "status message": statusMessage, "message": message]
        if let request = request {
            info["request"] = request
        }
        if let underlyingError = underlyingError {
            info["underlying error"] = underlyingError
        }
        return info
    }
}

public struct StormGlassAPIError: CustomNSError, Decodable {
    public static let errorDomain: String = "StormGlassKit.StormGlassNetworkError.APIError"

    var errors: [String: [String]]
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

    static func weatherURLRequest(
        apiKey: String,
        coordinate: CLLocationCoordinate2D,
        parameters: [String],
        start: Date?, end: Date?,
        sources: Set<WeatherDataSource>?
    ) throws -> URLRequest {
        assert(!parameters.isEmpty, "API expects at least one parameter")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: coordinate.latitude),
            URLQueryItem(name: "lng", value: coordinate.longitude),
            URLQueryItem(name: "params", value: parameters.joined(separator: ",")),
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
        guard let url = components.url else { throw StormGlassKitNetworkError.invalidRequest(reason: "Invalid URL components: \(components.description)") }
        var request: URLRequest = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        return request
    }
}

private extension URLQueryItem {
    init(name: String, value: Double) {
        self.init(name: name, value: String(value))
    }
}

private func validateNetworkResponse(
    decoder: JSONDecoder,
    data: Data,
    response: URLResponse,
    request: URLRequest
) throws  {
    let underlyingError = try? decoder.decode(StormGlassAPIError.self, from: data)
    guard let response = response as? HTTPURLResponse else {
        var error = StormGlassKitNetworkError.noResponse(for: request)
        error.underlyingError = underlyingError
        throw error
    }
    guard response.statusCode == 200 else {
        var error = StormGlassKitNetworkError.invalidStatus(response.statusCode, request: request)
        error.underlyingError = underlyingError
        throw error
    }
}
