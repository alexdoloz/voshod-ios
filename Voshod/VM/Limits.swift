//
//  Limits.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation

enum Limits {
    static let maxVMs = 1 << 9
    static let maxPluginsPerVM = 1 << 10
    static let maxChannelsPerPlugin = 1 << 12    
}
