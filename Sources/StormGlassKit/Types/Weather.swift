//
//  Weather.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import CoreLocation

public struct Weather: Decodable, Sendable, Hashable {
    public var periods: [WeatherPeriod]
    public var metadata: Metadata
    
    public init(periods: [WeatherPeriod], metadata: Weather.Metadata) {
        self.periods = periods
        self.metadata = metadata
    }
    
    enum CodingKeys: String, CodingKey {
        case periods = "hours"
        case metadata = "meta"
    }
}

extension Weather {
    public struct Metadata: Decodable, Sendable, Hashable {
        public var cost: Double
        public var dailyQuota: Int
        public var parameters: Set<WeatherMeasurementName>
        public var sources: Set<WeatherDataSource>?
        public var requestCount: Int
        public var start: String
        public var end: String
        public var latitude: CLLocationDegrees
        public var longitude: CLLocationDegrees
        public var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            latitude = try container.decode(CLLocationDegrees.self, forKey: .lat)
            longitude = try container.decode(CLLocationDegrees.self, forKey: .lng)
            cost = try container.decode(Double.self, forKey: .cost)
            dailyQuota = try container.decode(Int.self, forKey: .dailyQuota)
            parameters = try container.decode(Set<WeatherMeasurementName>.self, forKey: .params)
            sources = try container.decodeIfPresent(Set<WeatherDataSource>.self, forKey: .source)
            requestCount = try container.decode(Int.self, forKey: .requestCount)
            start = try container.decode(String.self, forKey: .start)
            end = try container.decode(String.self, forKey: .end)
        }
        
        enum CodingKeys: String, CodingKey {
            case lat
            case lng
            case cost
            case dailyQuota
            case params
            case requestCount
            case start
            case source
            case end
        }
    }
}
