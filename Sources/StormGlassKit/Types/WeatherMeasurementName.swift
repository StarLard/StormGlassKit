//
//  WeatherMeasurementName.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 11/19/21.
//

import Foundation

public enum WeatherMeasurementName: String, CaseIterable, Decodable, CodingKey, Sendable, Hashable {
    /// Air temperature in degrees celsius
    case airTemperature
    /// Air temperature at 80m above sea level in degrees celsius
    case airTemperature80m
    /// Air temperature at 100m above sea level in degrees celsius
    case airTemperature100m
    /// Air temperature at 1000hpa in degrees celsius
    case airTemperature1000hpa
    /// Air temperature at 800hpa in degrees celsius
    case airTemperature800hpa
    /// Air temperature at 500hpa in degrees celsius
    case airTemperature500hpa
    /// Air temperature at 200hpa in degrees celsius
    case airTemperature200hpa
    /// Air pressure in hPa
    case pressure
    /// Total cloud coverage in percent
    case cloudCover
    /// Direction of current. 0° indicates current coming from north
    case currentDirection
    /// Speed of current in meters per second
    case currentSpeed
    /// Wind gust in meters per second
    case gust
    /// Relative humidity in percent
    case humidity
    /// Proportion, 0-1
    case iceCover
    /// Mean precipitation in kg/m²
    case precipitation
    /// Depth of snow in meters
    case snowDepth
    /// Sea level relative to MSL
    case seaLevel
    /// Direction of swell waves. 0° indicates swell coming from north
    case swellDirection
    /// Height of swell waves in meters
    case swellHeight
    /// Period of swell waves in seconds
    case swellPeriod
    /// Direction of secondary swell waves. 0° indicates swell coming from north
    case secondarySwellPeriod
    /// Height of secondary swell waves in meters
    case secondarySwellDirection
    /// Period of secondary swell waves in seconds
    case secondarySwellHeight
    /// Horizontal visibility in km
    case visibility
    /// Water temperature in degrees celsius
    case waterTemperature
    /// Direction of combined wind and swell waves. 0° indicates waves coming from north
    case waveDirection
    /// Significant Height of combined wind and swell waves in meters
    case waveHeight
    /// Period of combined wind and swell waves in seconds
    case wavePeriod
    /// Direction of wind waves. 0° indicates waves coming from north
    case windWaveDirection
    /// Height of wind waves in meters
    case windWaveHeight
    /// Period of wind waves in seconds
    case windWavePeriod
    /// Direction of wind at 10m above sea level. 0° indicates wind coming from north
    case windDirection
    /// Direction of wind at 20m above sea level. 0° indicates wind coming from north
    case windDirection20m
    /// Direction of wind at 30m above sea level. 0° indicates wind coming from north
    case windDirection30m
    /// Direction of wind at 40m above sea level. 0° indicates wind coming from north
    case windDirection40m
    /// Direction of wind at 50m above sea level. 0° indicates wind coming from north
    case windDirection50m
    /// Direction of wind at 80m above sea level. 0° indicates wind coming from north
    case windDirection80m
    /// Direction of wind at 100m above sea level. 0° indicates wind coming from north
    case windDirection100m
    /// Direction of wind at 1000hpa. 0° indicates wind coming from north
    case windDirection1000hpa
    /// Direction of wind at 800hpa. 0° indicates wind coming from north
    case windDirection800hpa
    /// Direction of wind at 500hpa. 0° indicates wind coming from north
    case windDirection500hpa
    /// Direction of wind at 200hpa. 0° indicates wind coming from north
    case windDirection200hpa
    /// Speed of wind at 10m above sea level in meters per second.
    case windSpeed
    /// Speed of wind at 20m above sea level in meters per second.
    case windSpeed20m
    /// Speed of wind at 30m above sea level in meters per second.
    case windSpeed30m
    /// Speed of wind at 40m above sea level in meters per second.
    case windSpeed40m
    /// Speed of wind at 50m above sea level in meters per second.
    case windSpeed50m
    /// Speed of wind at 80m above sea level in meters per second.
    case windSpeed80m
    /// Speed of wind at 100m above sea level in meters per second.
    case windSpeed100m
    /// Speed of wind at 1000hpa in meters per second.
    case windSpeed1000hpa
    /// Speed of wind at 800hpa in meters per second.
    case windSpeed800hpa
    /// Speed of wind at 500hpa in meters per second.
    case windSpeed500hpa
    /// Speed of wind at 200hpa in meters per second.
    case windSpeed200hpa
    
    /// The dimension in which the query parameter is measured, if any.
    public var dimension: Dimension? {
        switch self {
        case .humidity, .iceCover, .precipitation: return nil
        case .airTemperature, .airTemperature80m, .airTemperature100m, .airTemperature1000hpa,
                .airTemperature800hpa, .airTemperature500hpa, .airTemperature200hpa, .waterTemperature:
            return UnitTemperature.celsius
        case .pressure: return UnitPressure.hectopascals
        case .cloudCover: return nil
        case .currentDirection, .swellDirection, .secondarySwellDirection, .waveDirection,
                .windWaveDirection, .windDirection, .windDirection20m, .windDirection30m,
                .windDirection40m, .windDirection50m, .windDirection80m, .windDirection100m,
                .windDirection1000hpa, .windDirection800hpa, .windDirection500hpa, .windDirection200hpa:
            return UnitAngle.degrees
        case .currentSpeed, .gust, .windSpeed, .windSpeed20m,
                .windSpeed30m, .windSpeed40m, .windSpeed50m, .windSpeed80m,
                .windSpeed100m, .windSpeed1000hpa, .windSpeed800hpa, .windSpeed500hpa,
                .windSpeed200hpa:
            return UnitSpeed.metersPerSecond
        case .snowDepth, .seaLevel, .swellHeight, .secondarySwellHeight,
                .waveHeight, .windWaveHeight:
            return UnitLength.meters
        case .swellPeriod, .secondarySwellPeriod, .wavePeriod, .windWavePeriod: return UnitDuration.seconds
        case .visibility: return UnitLength.kilometers
        }
    }
}
