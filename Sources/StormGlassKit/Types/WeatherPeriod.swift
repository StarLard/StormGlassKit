//
//  WeatherPeriod.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 11/19/21.
//

import Foundation
import os.log

public struct WeatherPeriod: Decodable, Sendable, Hashable {
    public var time: Date
    public var data: [WeatherMeasurementName: [WeatherDataSource: Double]]
    
    public init(time: Date, data: [WeatherMeasurementName : [WeatherDataSource : Double]]) {
        self.time = time
        self.data = data
    }
    
    /// Attempts to decode the weather period, trying all query parameters.
    ///
    /// If you know which parameters to expect, use `init(from:queryParameters:expectAllParameters:)`.
    ///
    /// - Parameter decoder: The decoder to use for decoding.
    public init(from decoder: Decoder) throws {
        try self.init(from: decoder, measurements: WeatherMeasurementName.allCases, expectAllMeasurements: false)
    }
    
    /// Attempts to decode the weather period, only decoding the given query parameters.
    /// - Parameters:
    ///   - decoder: The decoder to use for decoding.
    ///   - measurements: The measurements to decode.
    ///   - expectAllMeasurements: Whether or not it's expected that all given measurements should be present in the decoded data.
    ///   If `true`, this method will throw a `DecodingError` on the first missing measurement, otherwise it will log the error and continue decoding.
    public init(from decoder: Decoder, measurements: [WeatherMeasurementName], expectAllMeasurements: Bool = true) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(String.self, forKey: .time)
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timestamp) else {
            throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "\(timestamp) is not a valid ISO formatted date string")
        }
        time = date
        let dataContainer = try decoder.container(keyedBy: WeatherMeasurementName.self)
        var dataSets: [WeatherMeasurementName: [WeatherDataSource: Double]] = [:]
        for measurement in measurements {
            do {
                // For some reason decoding directly to `WeatherDataSource` doesn't work...
                let dataSet = try dataContainer.decode([String: Double].self, forKey: measurement)
                var sourcedDate: [WeatherDataSource: Double] = [:]
                for (sourceKey, value) in dataSet {
                    guard let source = WeatherDataSource(rawValue: sourceKey) else { continue }
                    sourcedDate[source] = value
                }
                dataSets[measurement] = sourcedDate
            } catch {
                if expectAllMeasurements {
                    throw error
                } else {
                    Logger.default.log(level: .error, "Failed to decode weather data for query parameter \(measurement.rawValue, privacy: .public): \(error.localizedDescription)")
                    continue
                }
            }
        }
        self.data = dataSets
    }
    
    enum CodingKeys: String, CodingKey {
        case time
    }
}
