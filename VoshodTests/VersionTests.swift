//
//  VersionTests.swift
//  VoshodTests
//
//  Created by Alexander Doloz on 18.04.2022.
//

import XCTest
@testable import Voshod

final class VersionTests: XCTestCase {
    let validStrings = [
        "0.0.0",
        "1",
        "1000000",
        "10.3",
        "3.4.5",
        "1.0.100",
        "10.0.0"
    ]
    let versions = [
        Version(major: 0, minor: 0, patch: 0),
        Version(major: 1),
        Version(major: 1000000),
        Version(major: 10, minor: 3),
        Version(major: 3, minor: 4, patch: 5),
        Version(major: 1, patch: 100),
        Version(major: 10)
    ]
    
    let invalidStrings = [
        "",
        "hello",
        "3.",
        "-1",
        "1.2.3.4",
        "1.x.2",
        "1..3.4",
        "1.2+",
        "3.2.-1",
        "3. 0.1"
    ]
    
    func testValidStrings() {
        zip(validStrings, versions).forEach {
            XCTAssertEqual(Version($0.0), $0.1)
        }
    }
    
    func testInvalidStrings() {
        invalidStrings.forEach { XCTAssertNil(Version($0)) }
    }
}
