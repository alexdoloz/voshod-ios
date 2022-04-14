//
//  Bridge.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

struct LuaState {
    private let state: OpaquePointer
    
//    init() {
//
//    }
//
    init(state: OpaquePointer) {
        self.state = state
    }
    
//    func convertTo(_ value: Any) {
//        
//    }
//    
//    func convertFrom() -> Any? {
//        return nil
//    }
    
    func put<T: LuaConvertible>(_ value: T?) {
        guard let value = value else {
            lua_pushnil(state)
            return
        }
        value.put(state: state)
    }
    
    func get<T: LuaConvertible>() -> T? {
        
        return nil
    }
}
