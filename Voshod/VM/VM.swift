//
//  VM.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

struct IdentifiedPlugin {
    var id: Id
    var plugin: Plugin
}

public final class MainThreadVM {
    
}

public final class VM {
    public init(pluginTypes: [Plugin.Type]) {
        guard let state = luaL_newstate() else {
            fatalError("💥 Failed to create lua_State")
        }
        luaL_openlibs(state)
        
        self.state = state
        
        makePluginMap(pluginTypes: pluginTypes)
    
        performPrerun()
    }
    
    public func run(script: String) throws {
        
    }
    
    public func cancel() {
        
    }
    
    private(set) var plugins: [IdentifiedPlugin] = []
    
    var name: String = "VM"
    
    var id: Int = 0
    
    func instantiatePlugin(with pluginName: String) -> Int {
        guard let pluginType = pluginMap[pluginName] else {
            fatalError("Unknown plugin name \"\(pluginName)\"")
        }
        let plugin = pluginType.provideInstance(to: id)
        plugins.append(IdentifiedPlugin(id: id, plugin: plugin))
        return id
    }
    
    func execute(closure: @escaping () -> Void) {
        // TODO: execute
    }
    
//    subscript (pluginId pluginId: Int) -> Plugin? {
//        get {
//            plugins.first(where: { $0.id == pluginId })?.plugin
//        }
//    }
//
//    public struct Id: Hashable {
//        var id: Int
//
//        init(_ id: Int) {
//            self.id = id
//        }
//
//        private static var takenIds = Set<Int>()
//
//        static func getFreeId() -> Id {
//            for i in 0...takenIds.count where !takenIds.contains(i) {
//                return Id(i)
//            }
//            fatalError("getFreeId – internal logic error")
//        }
//    }
    
//    private var plugins: [String: ]
    
//    private let pluginTypes: [Plugin.Type]
    
    private let state: OpaquePointer
    
    private var pluginMap: [String: Plugin.Type] = [:]
    
    static var vms: [Id: VM] = [:]
    
    private func makePluginMap(pluginTypes: [Plugin.Type]) {
        pluginTypes.forEach {
            let name = $0.name
            if pluginMap[name] != nil {
                fatalError("💥 Duplicate plugin names: \"\(name)\" for \(pluginMap[name]!) and \($0)")
            }
            pluginMap[name] = $0
        }
    }
    
    private func performPrerun() {
        do {
            let bundle = Bundle(for: Self.self)
            let prerunScriptURL = bundle
                .bundleURL
                .appendingPathComponent("Scripts")
                .appendingPathComponent("prerun.lua")
            let prerunScript = try String(contentsOf: prerunScriptURL)
            try run(script: prerunScript)
        } catch {
            fatalError("💥 Failed to execute prerun script\n\(error)")
        }
    }
}

//public

//fileprivate func createPlugin(_ state: OpaquePointer!) -> Int32 {
////    lua_isstring(state, 1)
////    lua_isstring(state, 2)
//    let vmId = VM.Id(lua_tointegerx(state, 2, nil))
////    let
//    let pluginName: String
////    VM.createPlugin(pluginName)
//    return 1
//}

//fileprivate func luaPluginSend(_ state: OpaquePointer!) -> Int32 {
//    // pluginId, channelId, payload
//    return 1
//}


























enum VMState {
    case idle
    case running
    case cancelling
}

enum VMCancellation {
    case disabled
    case enabled(opCount: Int)
}

struct VMOptions: OptionSet {
    let rawValue: Int
    
    static let ffi = VMOptions(rawValue: 1 << 0)
    static let jit = VMOptions(rawValue: 1 << 1)
    static let coroutines = VMOptions(rawValue: 1 << 2)
    static let defaultLibs = VMOptions(rawValue: 1 << 3)
    static let debug = VMOptions(rawValue: 1 << 4)
//    static let  VMOptions(rawValue: 1 << 3)
}

protocol VMProtocol: AnyObject {
    init(pluginTypes: [PluginProtocol.Type], aliases: [String: PluginProtocol.Type], options: VMOptions)
    func run(script: String) throws -> LuaConvertible?
    func cancel()
    
    var state: VMState { get }
    var cancellation: VMCancellation { get set }
}

struct VersionPattern {
    
}

struct Dependency {
    var name: String
    var version: VersionPattern
}

protocol PluginProtocol {
    static var dependencies: [Dependency] { get }
    static var name: String { get }
    
    static func provideInstance(vmId: Id) -> PluginProtocol
    
}
