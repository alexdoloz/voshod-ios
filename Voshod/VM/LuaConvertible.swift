//
//  LuaConvertible.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

public protocol LuaConvertible {
    init?(state: OpaquePointer)
    
    func put(state: OpaquePointer)
}

protocol LuaPrimitiveConvertible {
    init?(state: OpaquePointer)
    
    func put(state: OpaquePointer)
}

extension Int: LuaConvertible {
    public init?(state: OpaquePointer) {
        var isInteger = Int32(0)
        let result = lua_tointegerx(state, -1, &isInteger)
        if isInteger == 0 {
            return nil
        }
        self = result
    }
    
    public func put(state: OpaquePointer) {
        lua_pushinteger(state, self)
    }
}

extension Double: LuaConvertible {
    public init?(state: OpaquePointer) {
        var isNumber = Int32(0)
        let result = lua_tonumberx(state, -1, &isNumber)
        if isNumber == 0 {
            return nil
        }
        self = result
    }
    
    public func put(state: OpaquePointer) {
        lua_pushnumber(state, self)
    }
}

class LuaBox<T: AnyObject>: LuaConvertible {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    required init?(state: OpaquePointer) {
        guard let pointer = lua_touserdata(state, -1) else {
            return nil
        }
        value = pointer.load(as: T.self)
    }
    
    func put(state: OpaquePointer) {
        withUnsafePointer(to: value) { pointer in
            let rawPointer = UnsafeMutableRawPointer(mutating: pointer)
            lua_pushlightuserdata(state, rawPointer)
        }
    }
}
