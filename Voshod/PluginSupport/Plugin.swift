//
//  Plugin.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation

public protocol Plugin: AnyObject {
    var installerScript: String { get }
    var dependencies: [String] { get }
    
    static var dependencies: [Dependency] { get }
    static var specifier: Specifier { get set }
    
    static func provideInstance(for vm: VM, resolvedDependencies: [Plugin]) -> Plugin
    
    func receive(message: LuaReceivable, from vm: VM) -> LuaSendable
}

public extension Plugin {
    @discardableResult
    func send(message: LuaSendable, to vm: VM) throws -> LuaReceivable {
        return try vm.send(message: message, to: self)
    }
}
