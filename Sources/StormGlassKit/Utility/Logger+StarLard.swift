//
//  Logger+StarLard.swift
//  StormGlassKit
//
//  Created by Caleb Friden on 6/13/21.
//

import os.log

extension Logger {
    static let `default` = Logger(category: "default")
    static let api = Logger(category: "api")

    
    init(category: String) {
        self.init(subsystem: "com.starlard.storm-glass-kit", category: category)
    }
}
