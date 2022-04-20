//
//  Specifier.swift
//  Voshod
//
//  Created by Alexander Doloz on 20.04.2022.
//

import Foundation

public struct Specifier: Hashable {
    public let name: String
    public let version: Version
    
    init?(_ string: String) {
        let parts = string.split(separator: " ", omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            return nil
        }
        name = String(parts[0])
        guard Specifier.isProper(name: name) else { return nil }
        guard let version = Version(String(parts[1])) else { return nil }
        self.version = version
    }
    
    init?(name: String, version: Version) {
        guard Specifier.isProper(name: name) else { return nil }
        self.name = name
        self.version = version
    }
    
    static func isProper(name: String) -> Bool {
        guard !name.isEmpty else { return false }
        guard name.count < 100 else { return false }
        
        guard CharacterSet.letters.contains(name.unicodeScalars.first!)
            else { return false }
        
        for char in name.unicodeScalars.dropFirst() {
            if !CharacterSet.alphanumerics.contains(char) {
                return false
            }
        }
        return true
    }
    
    func aliased(with alias: String?) -> Specifier? {
        guard let alias = alias else { return self }
        guard Specifier.isProper(name: alias) else { return nil }
        return Specifier(name: alias, version: version)
    }
}
