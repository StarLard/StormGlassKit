//
//  DecodingTests.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 12/4/21.
//

import XCTest
@testable import StormGlassKit

final class DecodingTests: XCTestCase {
    func testMetadataDecoding() throws {
        let metadata = try JSONDecoder().decode(Weather.Metadata.self, from: metaData)
        XCTAssertEqual(metadata.cost, 1)
        XCTAssertEqual(metadata.requestCount, 6)
        XCTAssertEqual(metadata.start, "2021-06-14 06:00")
        XCTAssertTrue(metadata.parameters.contains(.swellHeight))
        XCTAssertEqual(metadata.sources?.contains(.noaa), true)
    }
    
    func testWeatherPeriodDecoding() throws {
        let period = try JSONDecoder().decode(WeatherPeriod.self, from: periodData)
        XCTAssertEqual(period.time, Date(timeIntervalSince1970: 1623650400))
        XCTAssertEqual(period.data.count, 7)
        XCTAssertEqual(period.data[.swellHeight]?[.noaa], 0.26)
        XCTAssertEqual(period.data[.waterTemperature]?[.stormGlass], 25.55)
        XCTAssertNil(period.data[.waterTemperature]?[.noaa])
    }
    
    func testWeatherDecoding() throws {
        let weather = try JSONDecoder().decode(Weather.self, from: weatherData)
        XCTAssertEqual(weather.periods.count, 2)
        XCTAssertEqual(weather.periods.first?.data[.waveHeight]?[.noaa], 0.56)
        XCTAssertEqual(weather.metadata.cost, 1)
    }
    
    func testAPIErrorDecoding() throws {
        let error = try JSONDecoder().decode(StormGlassAPIError.self, from: errorData)
        XCTAssertEqual(error.errors, ["params": ["time not valid. Should be one of: waterTemperature"]])
    }
    
    private let metaData: Data = """
    {
        "cost": 1,
        "dailyQuota": 50,
        "end": "2021-06-14 07:16",
        "lat": 19.64,
        "lng": -155.9969,
        "params": [
            "airTemperature",
            "currentDirection",
            "currentSpeed",
            "swellDirection",
            "swellHeight",
            "secondarySwellHeight",
            "secondarySwellDirection",
            "waterTemperature",
            "waveHeight"
        ],
        "requestCount": 6,
        "source": [
            "noaa"
        ],
        "start": "2021-06-14 06:00"
    }
    """.data(using: .utf8)!
    
    private let periodData: Data = """
    {
        "airTemperature": {
            "noaa": 23.59
        },
        "secondarySwellDirection": {
            "noaa": 187.6
        },
        "secondarySwellHeight": {
            "noaa": 0.29
        },
        "swellDirection": {
            "noaa": 206.12
        },
        "swellHeight": {
            "noaa": 0.26
        },
        "time": "2021-06-14T06:00:00+00:00",
        "waterTemperature": {
            "sg": 25.55
        },
        "waveHeight": {
            "noaa": 0.56
        }
    }
    """.data(using: .utf8)!
    
    private let weatherData: Data = """
    {
        "hours": [
            {
                "airTemperature": {
                    "noaa": 23.59
                },
                "secondarySwellDirection": {
                    "noaa": 187.6
                },
                "secondarySwellHeight": {
                    "noaa": 0.29
                },
                "swellDirection": {
                    "noaa": 206.12
                },
                "swellHeight": {
                    "noaa": 0.26
                },
                "time": "2021-06-14T06:00:00+00:00",
                "waterTemperature": {
                    "noaa": 25.55
                },
                "waveHeight": {
                    "noaa": 0.56
                }
            },
            {
                "airTemperature": {
                    "noaa": 23.62
                },
                "secondarySwellDirection": {
                    "noaa": 184.31
                },
                "secondarySwellHeight": {
                    "noaa": 0.29
                },
                "swellDirection": {
                    "noaa": 203.61
                },
                "swellHeight": {
                    "noaa": 0.27
                },
                "time": "2021-06-14T07:00:00+00:00",
                "waterTemperature": {
                    "noaa": 25.56
                },
                "waveHeight": {
                    "noaa": 0.56
                }
            }
        ],
        "meta": {
            "cost": 1,
            "dailyQuota": 50,
            "end": "2021-06-14 07:16",
            "lat": 19.64,
            "lng": -155.9969,
            "params": [
                "airTemperature",
                "currentDirection",
                "currentSpeed",
                "swellDirection",
                "swellHeight",
                "secondarySwellHeight",
                "secondarySwellDirection",
                "waterTemperature",
                "waveHeight"
            ],
            "requestCount": 6,
            "source": [
                "noaa"
            ],
            "start": "2021-06-14 06:00"
        }
    }
    """.data(using: .utf8)!
    
    let errorData = """
    {
        "errors": {
            "params": [
                "time not valid. Should be one of: waterTemperature"
            ]
        }
    }
    """.data(using: .utf8)!
}
