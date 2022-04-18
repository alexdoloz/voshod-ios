//
//  VersionPatternTests.swift
//  VoshodTests
//
//  Created by Alexander Doloz on 18.04.2022.
//

import XCTest
@testable import Voshod

final class VersionPatternTests: XCTestCase {
    let validPatterns = [
        "0+",
        "1.2.3",
        "1.2",
        "4",
        "10.5+",
        "2.3-",
        "1.2.3+",
        "10.[5:]",
        "1.1.[2:]",
        "2.3.[4:10]",
        "3.[5:100]",
        "2.[1:10]",
        "[1:20]",
        "2.3.5:3.5.1"
    ]
    
    let nonMatchesForValidPatterns: [[String]] = [
        [],
        ["1.2.0", "1.0.0", "1.2.4", "1.2.2", "2.2.3", "1.3.3"],
        ["1.3.5", "1.3.0", "2.2.0"],
        ["3.9.9", "5.1.1"],
        ["10.4.0", "10.4.9999", "3.3"],
        ["2.3.4", "2.3.10", "3.0.0", "2.4.5"],
        ["1.2.2", "1.1.100", "0.999.999"],
        ["10.4.0", "10.3.999", "11.6.0", "9.5.0"],
        ["1.1.1", "1.2.2", "2.1.3"],
        ["2.3.3", "2.3.11", "2.4.5", "3.3.5"],
        ["4.5.0", "3.110.0", "3.4.999", "2.2.2"],
        ["2.0.0", "2.11.11", "1.5.5"],
        ["0.1.0", "21.9.9"],
        ["2.3.4", "3.5.2", "0.0.0", "10.0.0"],
    ]
    
    let matchesForValidPatterns: [[String]] = [
        ["1", "1.4", "2.5.6", "1000000", "0.0.0", "0.0.1"],
        ["1.2.3"],
        ["1.2.0", "1.2.1", "1.2.100"],
        ["4.0.0", "4.5.2", "4.10.100", "4.0.1101010"],
        ["10.5.0", "10.5.1", "10.6", "11", "100"],
        ["2.3.0", "2.2.999", "2.1", "1.200.200"],
        ["1.2.3", "1.2.4", "1.3.1", "1.3.100", "2.0.0"],
        ["10.5", "10.5.1", "10.6", "10.100.0"],
        ["1.1.2", "1.1.5", "1.1.999"],
        ["2.3.4", "2.3.10", "2.3.5"],
        ["3.5.0", "3.6.100", "3.99.0", "3.100.0", "3.100.9999"],
        ["2.1.0", "2.1.999", "2.10.0", "2.10.983", "2.6.0", "2.5.100"],
        ["1.0.0", "4.6.999", "20.0.0", "20.100.200", "15.0.0", "11.0.0"],
        ["2.3.5", "3.5.1", "2.3.6", "2.10.0", "3.1.1", "3.5.0"]
    ]
    
    let invalidPatterns = [
        "",
        "some string",
        "1<2.3",
        "1.2<3.4",
        "1+5",
        "4+ ",
        "1.y",
        "1.*.2",
        "1.any",
        "1.-1.5",
        "-1",
        "4.4.-2",
        "10<4",
        "1. 4.5"
    ]
    
    func testInvalidPatterns() {
        invalidPatterns.forEach {
            XCTAssertNil(VersionPattern(string: $0), "Pattern for \($0) must be nil")
        }
    }
    
    func testValidPatterns() {
        for i in 0..<validPatterns.count {
            let patternString = validPatterns[i]
            let matches = matchesForValidPatterns[i]
            let nonMatches = nonMatchesForValidPatterns[i]
            let pattern = VersionPattern(string: patternString)!
            matches.forEach {
                XCTAssertTrue(pattern.matches(version: Version($0)!), "Pattern \(patternString) must match \($0)")
            }
            nonMatches.forEach {
                XCTAssertFalse(pattern.matches(version: Version($0)!), "Pattern \(patternString) must not match \($0)")
            }
        }
    }
}
