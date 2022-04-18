//
//  VersionPattern.swift
//  Voshod
//
//  Created by Alexander Doloz on 18.04.2022.
//

import Foundation

// 2.2.2
// 2.x
// 2
// 2.5<9
// 2.1.<100
// 2.5<
// 2.5+
// 2.<5
// 2.5-
// 1<5
// 1<5;6.0.1

//private 

public struct VersionPattern {
//    enum Kind {
//        case range(range: ClosedRange<Version>)
//        case majorRange(range: ClosedRange<UInt>)
//        case minorRange(major: UInt, range: ClosedRange<UInt>)
//        case patchRange(major: UInt, minor: UInt, range: ClosedRange<UInt>)
//    }
//
//    private let kind: Kind
    
    private let range: ClosedRange<Version>
    
    private static func parse(part: String) -> ClosedRange<UInt>? {
        if let value = UInt(part) { return value...value }
        guard
            part.first == "[",
            part.last == "]"
        else {
            return nil
        }
        let strippedBrackets = String(part.dropFirst().dropLast())
        let splitted = strippedBrackets
            .split(separator: ":", omittingEmptySubsequences: false)
            .map { String($0) }
        guard splitted.count == 2 else { return nil }
        if splitted.first == "" {
            guard let upper = UInt(splitted[1]) else { return nil }
            return 0...upper
        }
        if splitted.last == "" {
            guard let lower = UInt(splitted[0]) else { return nil }
            return lower...UInt.max
        }
        guard let lower = UInt(splitted[0]), let upper = UInt(splitted[1]) else {
            return nil
        }
        return lower...upper
    }
    
    public init?(string: String) {
        // range of 2 versions
        if string.contains(":") && !string.contains("[") {
            let parts = string.split(separator: ":", omittingEmptySubsequences: false)
            guard
                parts.count == 2,
                let versionFrom = Version(String(parts[0])),
                let versionTo = Version(String(parts[1]))
            else { return nil }
            range = versionFrom...versionTo
            return
        }
        let lastChar = string.last
        if lastChar == "+" || lastChar == "-" {
            let noSuffix = String(string.dropLast(1))
            guard let version = Version(noSuffix) else {
                return nil
            }
            range = lastChar == "+" ? version...Version.max : Version.min...version
            return
        }
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 3 && parts.count >= 1 else { return nil }
        // only the last component of version can contain ":"
        guard parts.dropLast(1).allSatisfy({ !String($0).contains(":") }) else {
            return nil
        }
        let ranges = parts.compactMap {
            VersionPattern.parse(part: String($0))
        }
        guard ranges.count == parts.count else { return nil }
        let defaultRange = 0...UInt.max
        let minVersion = Version(
            major: ranges.safeValue(at: 0, default: defaultRange).lowerBound,
            minor: ranges.safeValue(at: 1, default: defaultRange).lowerBound,
            patch: ranges.safeValue(at: 2, default: defaultRange).lowerBound
        )
        let maxVersion = Version(
            major: ranges.safeValue(at: 0, default: defaultRange).upperBound,
            minor: ranges.safeValue(at: 1, default: defaultRange).upperBound,
            patch: ranges.safeValue(at: 2, default: defaultRange).upperBound
        )
    
        range = minVersion...maxVersion
    }
    
    public init(version: Version) {
        range = version...version
    }
    
    public func matches(version: Version) -> Bool {
        return range.contains(version)
    }
}

private extension Array {
    func safeValue(at index: Int, default: Element) -> Element {
        guard indices.contains(index) else { return `default` }
        return self[index]
    }
}
