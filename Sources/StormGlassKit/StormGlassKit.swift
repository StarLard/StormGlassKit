//
//  StormGlassKit.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import Foundation
import os.log

/// Interfaces with Storm Glass API
public final class StormGlassKit {
    // MARK: Public
    
    public static var configuration: Configuration {
        guard let config = shared.configuration else {
            fatalError("`StormGlassKit.configure()` must be called at app launch.")
        }
        return config
    }
    
    public struct Configuration {
        public let apiKey: String
        
        public init?(bundle: Bundle) {
            guard let filePath = bundle.path(forResource: Self.fileName, ofType: Self.fileType),
                  let configurationDictionary = NSDictionary(contentsOfFile: filePath) else { return nil }
            self.init(configurationDictionary: configurationDictionary)
        }
        
        public init?(configurationDictionary: NSDictionary) {
            guard let key = configurationDictionary["API_KEY"] as? String else {
                return nil
            }
            self.init(apiKey: key)
        }
        
        public init(apiKey: String) {
            self.apiKey = apiKey
        }
        
        fileprivate static let fileName = "StormGlassKit-Configuration"
        fileprivate static let fileType = "plist"
    }
        
    /// Configures a default StormGlassKit app. Raises an exception if any configuration
    /// step fails. This method should be called after the app is launched and
    /// before using StormGlassKit services. This method is not thread safe and must
    /// be called on the main thread.
    public static func configure() {
        guard let configurationDictionary = shared.defaultConfigurationDictionary() else {
            preconditionFailure("""
                StormGlassKit could not find\n" a valid \(Configuration.fileName).\(Configuration.fileType)\n
                in your project. Please make one and include it in your app's bundle.
                """)
        }
        guard let configuration = Configuration(configurationDictionary: configurationDictionary) else {
            preconditionFailure("Configuration file was invalid. Please pass a valid configuration.")
        }
        configure(with: configuration)
    }
    
    /// Configures a StormGlassKit app with a custom configuration. Raises an exception
    /// if any configuration step fails. This method should be called after the app is launched
    /// and before using StormGlassKit services. This method is not thread safe and must
    /// be called on the main thread.
    /// - Parameter configuration: A custom configuration for your app.
    public static func configure(with configuration: Configuration) {
        assert(Thread.isMainThread)
        guard shared.configuration == nil else {
            preconditionFailure("StormGlassKit has already been configured. Only call \(#function) once per app launch.")
        }
        Logger.default.info("Configuring app.")
        shared.configuration = configuration
    }
    
    // MARK: Internal
    
    static let shared = StormGlassKit()
        
    // MARK: Private
    
    private var configuration: Configuration?
    private var appBundles: [Bundle] { [Bundle.main, Bundle(for: Self.self)] }
        
    private func pathForConfigurationDictionary(withResourceName resourceName: String, fileType: String, in bundles: [Bundle]) -> String? {
        for bundle in bundles {
            if let path = bundle.path(forResource: resourceName, ofType: fileType) {
                return path
            }
        }
        return nil
    }
    
    private func plistFilePath(withName fileName: String) -> String? {
        guard let plistFilePath = pathForConfigurationDictionary(withResourceName: fileName, fileType: Configuration.fileType, in: appBundles) else {
            Logger.default.fault("Could not locate configuration file: '\(fileName,privacy: .public).\(Configuration.fileType, privacy: .public)'.")
            return nil
        }
        return plistFilePath
    }
    
    private func defaultConfigurationDictionary() -> NSDictionary? {
        guard let filePath = plistFilePath(withName: Configuration.fileName), let configurationDictionary = NSDictionary(contentsOfFile: filePath) else {
            Logger.default.fault("The configuration file is not a dictionary: \(Configuration.fileName, privacy: .public).\(Configuration.fileType, privacy: .public)")
            return nil
        }
        return configurationDictionary
    }
}
