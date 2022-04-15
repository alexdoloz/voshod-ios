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
    var vm: VM { get }
    
    static var dependencies: [Dependency] { get }
    static var version: Version { get }
    static var name: String { get }
    
    static func provideInstance(for vm: VM, resolvedDependencies: [String: Plugin]) -> Plugin
    
    func receive(message: VM.Value) -> VM.Value
}
