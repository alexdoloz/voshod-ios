//
//  Version.swift
//  Voshod
//
//  Created by Alexander Doloz on 18.04.2022.
//

import Foundation

public struct Version {
    public let major: UInt
    public let minor: UInt
    public let patch: UInt
    
    public init(major: UInt = 0, minor: UInt = 0, patch: UInt = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public init?(_ string: String) {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 3 && parts.count > 0 else { return nil }
        let intParts = parts.compactMap { UInt($0) }
        guard intParts.count == parts.count else { return nil }
        major = intParts[0]
        minor = intParts.count >= 2 ? intParts[1] : 0
        patch = intParts.count >= 3 ? intParts[2] : 0
    }
    
    public static let min = Version(major: 0, minor: 0, patch: 0)
    public static let max = Version(major: .max, minor: .max, patch: .max)
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

extension Version: Comparable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
        return false
    }
}

extension Version: Hashable {}
