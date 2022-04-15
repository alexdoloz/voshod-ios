//
//  Bridge.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

struct LuaState {
    enum Error: Swift.Error {
        case takeError(String)
        case luaError(String)
    }
    
    private let state: OpaquePointer
    
    init(state: OpaquePointer) {
        self.state = state
    }
    
    init?() {
        guard let state = luaL_newstate() else {
            return nil
        }
        self.state = state
    }
    
    func openLibs() {
        luaL_openlibs(state)
    }
    
    func loadString(script: String) throws {
        try callLuaAPI { luaL_loadstring(state, script) }
    }
    
    func pcall(numberOfArgs: Int = 0) throws {
        try callLuaAPI { lua_pcall(state, Int32(numberOfArgs), LUA_MULTRET, 0) }
    }
    
    func pcall(globalFunctionName: String, args: [VM.Value], numresults: Int) throws -> [VM.Value] {
        lua_getfield(state, LUA_GLOBALSINDEX, globalFunctionName)
        args.forEach { put(value: $0) }
        try pcall(numberOfArgs: args.count)
        let resultsArray = try (0..<numresults).map { _ in
            try take()
        }
        return resultsArray.reversed()
    }
    
    private func callLuaAPI(closure: () -> Int32) throws {
        let status = closure()
        guard status != LUA_OK else { return }
        let error = popError(fallback: "Unknown Lua error")
        throw Error.luaError(error)
    }
    
    private func popError(fallback: String = "") -> String {
        let errorString = lua_tolstring(state, -1, nil)
            .flatMap { String(cString: $0) }
            ?? fallback
        lua_settop(state, -2)
        return errorString
    }
    
    func register(function: @escaping lua_CFunction, name: String) {
        lua_pushcclosure(state, function, 0)
        lua_setfield(state, LUA_GLOBALSINDEX, name)
    }
    
    func put(value: VM.Value) {
        // FIXME: checkstack
        switch value {
        case .int(let int): lua_pushinteger(state, int)
        case .double(let double): lua_pushnumber(state, double)
        case .string(let string): lua_pushstring(state, string)
        case .pointer(let pointer): lua_pushlightuserdata(state, pointer)
        case .array(let array):
            lua_createtable(state, Int32(array.count), 0)
            for (offset, element) in array.enumerated() {
                put(value: element)
                lua_rawseti(state, -2, Int32(offset) + 1)
            }
        case .dictionary(let dictionary):
            lua_createtable(state, 0, Int32(dictionary.count))
            dictionary.forEach {
                put(value: .string($0.key))
                put(value: $0.value)
                lua_rawset(state, -3)
            }
        case .nil: lua_pushnil(state)
        case .bool(let bool): lua_pushboolean(state, bool ? 1 : 0)
        }
    }
    
    func take() throws -> VM.Value {
        let valueType = lua_type(state, -1)
        switch valueType {
        case LUA_TNIL: return .nil
        case LUA_TNUMBER:
            var isInteger = Int32(0)
            let int = lua_tointegerx(state, -1, &isInteger)
            if isInteger > 0 { return .int(int) }
            return .double(lua_tonumber(state, -1))
        case LUA_TUSERDATA:
            return .pointer(lua_touserdata(state, -1))
        case LUA_TSTRING:
            let string = String(cString: lua_tolstring(state, -1, nil))
            return .string(string)
        case LUA_TBOOLEAN:
            return .bool(lua_toboolean(state, -1) > 0)
        case LUA_TTABLE:
            let length = lua_objlen(state, -1)
            let tableIndex = lua_gettop(state)
            if length == 0 {
                // dictionary
                lua_pushnil(state)
                var dictionary = [String: VM.Value]()
                while lua_next(state, tableIndex) != 0 {
                    guard lua_isstring(state, -2) != 0 else {
                        let keyType = String(cString: lua_typename(state, -2))
                        let key = String(cString: lua_tolstring(state, -2, nil))
                        lua_settop(state, lua_gettop(state) - 2)
                        throw Error.takeError("""
                        Only tables with string keys can be passed to native side;
                        received key \(key) of type \(keyType)
                        """)
                    }
                    let key = String(cString: lua_tolstring(state, -2, nil))
                    let value = try take()
                    lua_settop(state, lua_gettop(state) - 1)
                    dictionary[key] = value
                }
                return .dictionary(dictionary)
            } else {
                // array
                var array = [VM.Value]()
                for i in 1...length {
                    lua_rawgeti(state, -1, Int32(i))
                    let value = try take()
                    array.append(value)
                    lua_settop(state, lua_gettop(state) - 1)
                }
                return .array(array)
            }
        default: throw Error.takeError("Can't pass values of type \(valueType) to the native side;")
        }
    }
}
