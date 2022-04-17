//
//  LuaNil.swift
//  Voshod
//
//  Created by Alexander Doloz on 17.04.2022.
//

import Foundation

public struct LuaNil: Hashable {
    public static let `nil` = LuaNil()
    private init() {}
}
