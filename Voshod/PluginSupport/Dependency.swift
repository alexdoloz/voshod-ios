//
//  Dependency.swift
//  Voshod
//
//  Created by Alexander Doloz on 18.04.2022.
//

import Foundation

public struct Dependency {
    public let name: String
    public let version: VersionPattern
    public let isRequired: Bool
}
