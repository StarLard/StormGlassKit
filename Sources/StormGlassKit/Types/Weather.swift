//
//  Weather.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import CoreLocation

public struct Weather: Decodable {
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
    public struct Metadata: Decodable {
        public var cost: Double
        public var dailyQuota: Int
        public var parameters: Set<WeatherQueryParameter>
        public var sources: Set<WeatherDataSource>
        public var requestCount: Int
        public var start: String
        public var end: String
        public var coordinate: CLLocationCoordinate2D
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let lat = try container.decode(CLLocationDegrees.self, forKey: .lat)
            let lng = try container.decode(CLLocationDegrees.self, forKey: .lng)
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            cost = try container.decode(Double.self, forKey: .cost)
            dailyQuota = try container.decode(Int.self, forKey: .dailyQuota)
            parameters = try container.decode(Set<WeatherQueryParameter>.self, forKey: .params)
            sources = try container.decode(Set<WeatherDataSource>.self, forKey: .source)
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
