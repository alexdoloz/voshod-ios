//
//  ArrayProxy.swift
//  Voshod
//
//  Created by Alexander Doloz on 16.04.2022.
//

import Foundation
import LuaJIT

final class ArrayProxy<T>: LuaStackSendable {
    let array: [T]
    
    init(array: [T]) {
        self.array = array
    }
    
    func put(on state: OpaquePointer) {
        guard let userdata = lua_newuserdata(state, MemoryLayout<UnsafeMutableRawPointer>.size) else {
            print("Can't put array proxy for \(array) on stack")
            return
        }
        let proxyPtr = userdata.bindMemory(to: UnsafeMutableRawPointer.self, capacity: 1)

        proxyPtr.pointee = Unmanaged<ArrayProxy>.passRetained(self).toOpaque()
    }
//
//    {}
//    metatable = {
//        ud = lightuserdata,
//        __index = metatable,
//        eq = ud1 == ud2,
//    }
}

protocol Proxyable {
    
}

final class NativeObjectProxy<O: Proxyable>: LuaStackSendable {
    
    
    func put(on state: OpaquePointer) {
        
    }
}

