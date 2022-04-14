//
//  Plugin.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation


public protocol Plugin: AnyObject {
    static var name: String { get }
    static var dependencies: [String] { get }
    
    static func provideInstance(to vmId: Int) -> Self
    var installerScript: String { get }
    var dependencies: [String] { get }
    
    func receive(message: LuaConvertible, for channelId: Int) -> LuaConvertible
}

public extension Plugin {
    func send(payload: LuaConvertible, to channelId: Id) {
        
    }
}
