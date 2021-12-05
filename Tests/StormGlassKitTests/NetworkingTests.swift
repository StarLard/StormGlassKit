//
//  NetworkingTests.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 12/4/21.
//

import XCTest
@testable import StormGlassKit
import CoreLocation

final class NetworkingTests: XCTestCase {
    func testRequestComponents() {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: "19.594379"),
            URLQueryItem(name: "lng", value: "-155.971668"),
            URLQueryItem(name: "params", value: "swellHeight,airTemperature"),
        ]
        let components = StormGlassKit.urlComponents(apiEndpoint: "weather/point", queryItems: queryItems)
        
        guard let url = components.url else {
            XCTFail("Components URL was nil")
            return
        }
        
        XCTAssertEqual(url.absoluteString,
                       "https://api.stormglass.io/v2/weather/point?lat=19.594379&lng=-155.971668&params=swellHeight,airTemperature")
    }
    
    func testRequestURL() throws {
        let apiKey = "iLikeTurtles"
        let coordinate = CLLocationCoordinate2D(latitude: 19.594379, longitude: -155.971668)
        let measurements: Set<WeatherMeasurementName> = [.swellHeight, .airTemperature]
        let start = Date(timeIntervalSince1970: 1635760800.0)
        let end = Date(timeIntervalSince1970: 1635847200.0)
        
        StormGlassKit.configure(with: .init(apiKey: apiKey))
        let request = try StormGlassKit.weatherURLRequest(coordinate: coordinate, parameters: measurements.map(\.rawValue), start: start, end: end, sources: nil)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), apiKey)
    }
}
