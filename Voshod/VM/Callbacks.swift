//
//  Callbacks.swift
//  Voshod
//
//  Created by Alexander Doloz on 14.04.2022.
//

import Foundation
import LuaJIT

func __voshod_resolve_specifier(_ state: OpaquePointer!) -> Int32 {
    // TODO: Обработка версий, обработка ошибок
    let vmUD = lua_touserdata(state, 1)
    let specifier = String(cString: lua_tolstring(state, 2, nil))
    guard let vm = vmUD?.load(as: VM.self) else {
        fatalError("No such vm \(String(describing: vmUD))")
    }
    let parts = specifier.split(separator: " ")
    let name = String(parts[0])
    let version = String(parts[1])
    lua_pushstring(state, name)
    lua_pushstring(state, version)
    return 2
}

func __voshod_create_plugin(_ state: OpaquePointer!) -> Int32 {
    // TODO: Обработка версий, обработка ошибок
    
    let specifier = String(cString: lua_tolstring(state, 2, nil))
    guard
        let vmUD = lua_touserdata(state, 1)
    else {
        fatalError("Error finding vm")
    }
    
    let vm = Unmanaged<VM>.fromOpaque(vmUD).takeUnretainedValue()
//    let version = String(parts[1])
    let plugin = vm.instantiatePlugin(with: specifier)
    let pluginPtr = Unmanaged.passUnretained(plugin as AnyObject).toOpaque()
    lua_pushlightuserdata(state, pluginPtr)
    
    return 1
}

func __voshod_get_installer(_ state: OpaquePointer!) -> Int32 {
    // TODO: Обработка версий, обработка ошибок
    let pluginUD = lua_touserdata(state, 1)!
    let plugin = Unmanaged<AnyObject>.fromOpaque(pluginUD).takeUnretainedValue() as! Plugin
    let installer = plugin.installerScript
    lua_pushstring(state, installer)
    return 1
}

func __voshod_send_message(_ state: OpaquePointer!) -> Int32 {
    let pluginUD = lua_touserdata(state, 1)!
    let plugin = Unmanaged<AnyObject>.fromOpaque(pluginUD).takeUnretainedValue() as! Plugin
    let st = LuaState(state: state)
    do {
        let value = try st.take()
        let response = plugin.receive(message: value)
        st.put(value: response)
    } catch {
        fatalError("Error sending message Lua -> Native: \(error)")
    }
    return 1
}

public extension Plugin {
    @discardableResult
    func send(message: VM.Value) -> VM.Value {
        return vm.send(message: message, to: self) 
    }
}
