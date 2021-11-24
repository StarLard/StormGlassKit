//
//  WeatherDataSource.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation

public enum WeatherDataSource: String, CaseIterable, Decodable {
    /// Germany’s National Meteorological Service, the Deutscher Wetterdienst
    case icon
    /// Germany’s National Meteorological Service, the Deutscher Wetterdienst
    case dwd
    /// The National Oceanic and Atmospheric Administration
    case noaa
    /// French National Meteorological service
    case meteoFrance = "meteo"
    /// United Kingdom’s national weather service, The UK MetOffice
    case ukMetOffice = "meto"
    /// Danish Defence Centre for Operational Oceanography
    case fcoo
    /// The Finnish Meteorological Institution
    case fmi
    /// Norwegian Meteorological Institute and NRK
    case yr
    /// Swedish Meteorological and Hydrological Institute
    case smhi
    /// StormGlass handpicked local forecast in each geographical area
    case stormGlass = "sg"
}
