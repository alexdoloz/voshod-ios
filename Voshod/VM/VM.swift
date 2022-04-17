//
//  VM.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

//struct IdentifiedPlugin {
//    var id: Id
//    var plugin: Plugin
//}

public final class VM {
    private let state: LuaState
    
    private let options: Options
    
    public private(set) var plugins: [Plugin] = []
    
    private(set) var id: Int = 0
    
    private let resolver: DependencyResolver
    
    public init(
        pluginTypes: [Plugin.Type],
        aliases: [String: Plugin.Type] = [:],
        options: Options = .default
    ) throws {
        guard let state = LuaState() else {
            throw Error.stateInitializationFailure
        }
        
        state.openLibs()
        
        self.options = options
        self.state = state
        
        resolver = try DependencyResolver(pluginTypes: pluginTypes, aliases: aliases)
    
        registerCallbacks()
        try performPrerun()
    }
    
    public func run(script: String, params: [LuaSendable] = []) throws {
        try state.loadString(script: script)
        params.forEach { state.put(value: $0) }
        try state.pcall(numberOfArgs: params.count)
    }
    
    public func cancel() {
        
    }
    
    func instantiatePlugin(with specifier: String) -> Plugin {
        guard let pluginType = try? resolver.resolve(specifier: specifier) else {
            fatalError("Failed to resolve specifier \(specifier)")
            // TODO: Мягче
        }
        
        // TODO: Проверка зависимостей
        let plugin = pluginType.provideInstance(for: self, resolvedDependencies: [:])
        plugins.append(plugin)
//        let pluginId = Hub.shared.register(plugin: plugin)
//        plugins.append(plugin: plugin)
        return plugin
    }
    
    func send(message: LuaSendable, to plugin: Plugin) throws -> LuaReceivable {
        // TODO: Поддержка корутин, обработка ошибок, возврат значения
        let pluginPtr = Unmanaged<AnyObject>.passUnretained(plugin).toOpaque()
        let results = try state.pcall(
            globalFunctionName: "__voshod_receive_message",
            args: [pluginPtr, message],
            expectedResults: 1
        )
        return results.first ?? LuaNil.nil
    }
}

private extension VM {
    func prepare(prerunScript: String) -> String {
        let prefix = """
        local bundlePath = "\(Bundle.main.bundlePath)"
        local voshodScriptsPath = "\(Bundle(for: Self.self).bundlePath)/Scripts/"
        """
        return prefix + prerunScript
    }
    
    func performPrerun() throws {
        let bundle = Bundle(for: Self.self)
        let prerunScriptURL = bundle
            .bundleURL
            .appendingPathComponent("Scripts")
            .appendingPathComponent("prerun.lua")
        let prerunScript = prepare(
            prerunScript: try String(contentsOf: prerunScriptURL)
        )
        try run(
            script: prerunScript,
            params: [Unmanaged<VM>.passUnretained(self).toOpaque()]
        )
    }
    
    func registerCallbacks() {
        state.register(function: __voshod_resolve_specifier, name: "__voshod_resolve_specifier")
        state.register(function: __voshod_create_plugin, name: "__voshod_create_plugin")
        state.register(function: __voshod_get_installer, name: "__voshod_get_installer")
        state.register(function: __voshod_send_message, name: "__voshod_send_message")
    }
}

public extension VM {
    enum Error: Swift.Error {
        case stateInitializationFailure
        case luaError(String)
    }

    enum Cancellation {
        case disabled
        case enabled(opCount: Int)
    }

    enum State {
        case idle
        case running
        case cancelling
    }

    struct Options: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let ffi = Options(rawValue: 1 << 0)
        public static let jit = Options(rawValue: 1 << 1)
        public static let coroutines = Options(rawValue: 1 << 2)
        public static let defaultLibs = Options(rawValue: 1 << 3)
        public static let debug = Options(rawValue: 1 << 4)
        public static let os = Options(rawValue: 1 << 5)
        public static let metatables = Options(rawValue: 1 << 6)
        public static let load = Options(rawValue: 1 << 7)
        public static let io = Options(rawValue: 1 << 8)
        public static let `default`: Options = [
            .coroutines,
            .defaultLibs,
            .metatables
        ]
    }
}
