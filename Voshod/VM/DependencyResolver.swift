//
//  DependencyResolver.swift
//  Voshod
//
//  Created by Alexander Doloz on 15.04.2022.
//

import Foundation

final class DependencyResolver {
    enum Error: Swift.Error {
        case resolveFailure(String)
        case nameDuplication(Plugin.Type, Plugin.Type)
    }
    
    private let pluginTypes: [Plugin.Type]
    private let aliases: [String: Plugin.Type]
    
    private var pluginMap: [String: Plugin.Type] = [:]
    
    init(pluginTypes: [Plugin.Type], aliases: [String: Plugin.Type]) throws {
        self.pluginTypes = pluginTypes
        self.aliases = aliases
        try makePluginMap()
    }
    
    func resolve(specifier: String) throws -> Plugin.Type {
        // Реализовать
        let name = String(specifier.split(separator: " ")[0])
        guard let pluginType = pluginMap[name] else {
            throw Error.resolveFailure(specifier)
        }
        return pluginType
    }
    
    func makePluginMap() throws {
        try pluginTypes.forEach { type in
            let alias = aliases.first(where: { key, value in value == type })?.key
            let name = alias ?? type.name
            if let otherType = pluginMap[name] {
                throw Error.nameDuplication(type, otherType)
            }
            pluginMap[name] = type
        }
    }
}
