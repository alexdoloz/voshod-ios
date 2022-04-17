//
//  LuaConvertible.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

public protocol LuaSendable {
    func put(to state: OpaquePointer)
}


public protocol LuaReceivable {}

public typealias LuaConvertible = LuaSendable & LuaReceivable

extension Int: LuaConvertible {
    public static func take(from state: OpaquePointer) -> Self? {
        var isInteger = Int32(0)
        let result = lua_tointegerx(state, -1, &isInteger)
        if isInteger == 0 { return nil }
        return result
    }
    
    public func put(to state: OpaquePointer) {
        lua_pushinteger(state, self)
    }
}

extension Double: LuaConvertible {
    public static func take(from state: OpaquePointer) -> Self? {
        return lua_tonumber(state, -1)
    }
    
    public func put(to state: OpaquePointer) {
        lua_pushnumber(state, self)
    }
}

extension String: LuaConvertible {
    public static func take(from state: OpaquePointer) -> Self? {
        var length = 0
        guard let pointer = lua_tolstring(state, -1, &length) else { return nil }
        return String(
            bytesNoCopy: UnsafeMutableRawPointer(mutating: pointer),
            length: length,
            encoding: .utf8,
            freeWhenDone: false
        )
        
        // TODO: Убедиться, что метод безопасный
    }
    
    public func put(to state: OpaquePointer) {
        lua_pushstring(state, self.cString(using: .utf8))
    }
}

extension Bool: LuaConvertible {
    public static func take(from state: OpaquePointer) -> Self? {
       return lua_toboolean(state, -1) != 0
    }
    
    public func put(to state: OpaquePointer) {
        lua_pushboolean(state, self ? 1 : 0)
    }
}

extension LuaNil: LuaConvertible {
    public static func take(from state: OpaquePointer) -> Self? {
        return .nil
    }
    
    public func put(to state: OpaquePointer) {
        lua_pushnil(state)
    }
}

extension Array: LuaReceivable where Element == LuaReceivable {}

extension Array: LuaSendable where Element == LuaSendable {
    public func put(to state: OpaquePointer) {
        lua_createtable(state, Int32(count), 0)
        self.enumerated().forEach {
            $0.element.put(to: state)
            lua_rawseti(state, -2, Int32($0.offset + 1))
        }
    }
}

extension Dictionary: LuaSendable where Value == LuaSendable, Key == String {
    public func put(to state: OpaquePointer) {
        lua_createtable(state, 0, Int32(count))
        forEach {
            $0.key.put(to: state)
            $0.value.put(to: state)
            lua_rawset(state, -3)
        }
    }
}

extension Dictionary: LuaReceivable where Value == LuaReceivable, Key == String {
}

extension UnsafeMutableRawPointer: LuaConvertible {
    public func put(to state: OpaquePointer) {
        lua_pushlightuserdata(state, self)
    }
}
