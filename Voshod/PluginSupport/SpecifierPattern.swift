//
//  SpecifierPattern.swift
//  Voshod
//
//  Created by Alexander Doloz on 20.04.2022.
//

import Foundation

public struct SpecifierPattern: Hashable {
    public let name: String
    public let versionPattern: VersionPattern
    
    init?(_ string: String) {
        let parts = string.split(separator: " ", omittingEmptySubsequences: false)
        guard parts.count == 1 || parts.count == 2 else {
            return nil
        }
        name = String(parts[0])
        guard Specifier.isProper(name: name) else { return nil }
        let patternString = parts.count == 2 ? String(parts[1]) : "0+"
        guard let versionPattern = VersionPattern(patternString) else {
            return nil
        }
        self.versionPattern = versionPattern
    }
    
    public func matches(specifier: Specifier) -> Bool {
        return name == specifier.name &&
            versionPattern.matches(version: specifier.version)
    }
}
