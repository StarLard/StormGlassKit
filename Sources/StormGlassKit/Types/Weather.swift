//
//  Weather.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import CoreLocation

public struct Weather: Decodable {
    public var hours: [Hour]
    public var meta: Metadata
}

extension Weather {
    public struct Hour: Decodable {
        public var time: Date
        public var data: [WeatherQueryParameter: [WeatherDataSource: Double]]
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let timestamp = try container.decode(String.self, forKey: .time)
            let formatter = ISO8601DateFormatter()
            guard let date = formatter.date(from: timestamp) else {
                throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "\(timestamp) is not a valid ISO formatted date string")
            }
            time = date
            let dataContainer = try decoder.container(keyedBy: WeatherQueryParameter.self)
            var dataSets: [WeatherQueryParameter: [WeatherDataSource: Double]] = [:]
            for key in WeatherQueryParameter.allCases {
                // For some reason decoding directly to `WeatherDataSource` doesn't work...
                guard let dataSet = try? dataContainer.decode([String: Double].self, forKey: key) else { continue }
                var sourcedDate: [WeatherDataSource: Double] = [:]
                for (sourceKey, value) in dataSet {
                    guard let source = WeatherDataSource(rawValue: sourceKey) else { continue }
                    sourcedDate[source] = value
                }
                dataSets[key] = sourcedDate
            }
            data = dataSets
        }
        
        enum CodingKeys: String, CodingKey {
            case time
        }
    }
    
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
