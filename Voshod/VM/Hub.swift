//
//  Hub.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

final class Hub {
    static let shared = Hub()
    
    private var vmIdStorage = IdStorage()
    private var pluginIdStorage = IdStorage()
    
    private var vms: [VM] = []
    
    private var plugins: [Plugin] {
        vms.flatMap { $0.plugins }.map { $0.plugin }
    }
    
    func claimId(for realm: IdRealm) -> Id {
        do {
            switch realm {
            case .plugins: return try pluginIdStorage.claimId()
            case .vms: return try vmIdStorage.claimId()
            }
        } catch {
            fatalError("💥 Unable to claim id for \(realm)")
        }
    }
    
    var channelsCounts: [Int] = []
    
    func extract(fromGlobal channelId: Int) -> (vmId: Int, pluginId: Int, localChannelId: Int) {
        var id = channelId
        let localChannelId = id % Limits.maxChannelsPerPlugin
        id /= Limits.maxChannelsPerPlugin
        let pluginId = id % Limits.maxPluginsPerVM
        id /= Limits.maxPluginsPerVM
        let vmId = id % Limits.maxVMs
        return (vmId, pluginId, localChannelId)
    }
    
    subscript (vmId vmId: Int) -> VM? {
        get {
            guard vms.indices.contains(vmId) else { return nil }
            return vms[vmId]
        }
        set {
            guard vmId >= 0 else { return }
            if vmId >= vms.count {
                assert(vmId < Limits.maxVMs, "Attempt to create vm with too big id \(vmId); max possible is \(Limits.maxVMs - 1)")
                let currentCount = vms.count
                let additionalCount = min(currentCount, Limits.maxVMs - currentCount)
                vms = vms + [VM?](repeating: nil, count: additionalCount)
            }
            vms[vmId] = newValue
        }
    }
    
    var freeVMId: Int {
        let id = vms.firstIndex(where: { $0 == nil })
        return id ?? vms.count
    }
    
//    func reserveChannelIds(count: Int, for pluginId: Int) -> [Int] {
//        return []
//    }
    
//    func freeChannelIds(for pluginId: Int) {
//
//    }
    
    func send<R: LuaConvertible>(payload: LuaConvertible, to channelId: Int) -> R? {
        return nil
    }
    
    func receive<R: LuaConvertible>(message: R, from channelId: Int) -> LuaConvertible? {
        let (vmId, pluginId, localChannelId) = extract(fromGlobal: channelId)
        guard let vm = self[vmId: vmId] else {
            print("⚠️ Channel \(channelId) : received message for nonexisting VM \(vmId)")
            return nil
        }
        guard let plugin = vm[pluginId: pluginId] else {
            print("⚠️ Channel \(channelId) : received message for nonexisting plugin \(pluginId) in VM \(vm.name) \(vmId)")
            return nil
        }
        vm.execute { // Не здесь
            plugin.receive(message: message, for: localChannelId)
        }
        
        return nil
    }
}

//func voshod_native_receive(_ state: OpaquePointer) -> Int {
//    lua_tonumberx(<#T##L: OpaquePointer!##OpaquePointer!#>, <#T##idx: Int32##Int32#>, <#T##isnum: UnsafeMutablePointer<Int32>!##UnsafeMutablePointer<Int32>!#>)
//    let (vmId, pluginId, localChannelId) = Hub.shared.extract(fromGlobal: channelId)
//}

//func findPlugin(for channelId: Int) -> Plugin? {
//    return nil
//}

extension Plugin {
    func receive(message: LuaConvertible?) -> LuaConvertible? {
        return nil
    }
    
    func send(message: LuaConvertible?) -> LuaConvertible? {
        return nil
    }
}
//func voshod_create_plugin(_ state: OpaquePointer)

func findVM(for state: OpaquePointer) -> VM? {
    return nil
}

func findPlugin(for pluginId: Int) -> Plugin? {
    return nil
}

func take(_ state: OpaquePointer!) throws -> LuaConvertible? {
    return nil
}

func put(_ state: OpaquePointer!, value: LuaConvertible?) {
    
}

func findVM(by vmId: Int) -> VM? {
    return nil
}

func voshod_native_plugin_create(_ state: OpaquePointer) -> Int {
    let vmId = lua_tointeger(state, 1)
    let pluginName = String(cString: lua_tolstring(state, 2, nil))
    guard let vm = findVM(by: vmId) else {
        fatalError("Not found VM with id \(vmId)")
    }
    let pluginId = vm.instantiatePlugin(with: pluginName)
    lua_pushinteger(state, pluginId)
    return 1
}

func voshod_native_receive(_ state: OpaquePointer!) -> Int {
    let pluginId = lua_tointeger(state, 1)
    guard let plugin = findPlugin(for: pluginId) else {
        print("No plugin \(pluginId)")
        return 0
    }
    let message = try? take(state) // error handling
    let response = plugin.receive(message: message)
    put(state, value: response)
    
    return 1
}
