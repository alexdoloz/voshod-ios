//
//  DependencyResolver.swift
//  Voshod
//
//  Created by Alexander Doloz on 15.04.2022.
//

import Foundation

final class DependencyResolver {
    enum Error: Swift.Error {
        case initializationFailure(String)
        case resolveFailure(String)
        case nameDuplication(Plugin.Type, Plugin.Type)
        case circularDependency([Specifier])
    }
    
    private var pluginMap: [Specifier: Plugin.Type] = [:]
    
    init(pluginTypes: [Plugin.Type], aliases: [String: Plugin.Type]) throws {
        try makePluginMap(pluginTypes: pluginTypes, aliases: aliases)
    }
    
    private(set) var specifiers: [Specifier] = []
    
    /// Parses and resolves given plugin specifier.
    /// - Throws: `DependencyResolver.Error` if necessary plugins can't be found. Also throws an error if circular dependency was found.
    /// - Parameter specifierPattern: Specifier pattern (e.g. `"JSON 5.4.4+"`)
    /// - Returns: Array of specifiers such that every specifier for dependency is before the specifier of plugin which depends on it. Array ends with specifier corresponding to given `specifierPattern`.
    func resolve(specifierPattern: SpecifierPattern) throws -> DependencyTree {
        return try resolve(specifierPattern: specifierPattern, origins: [])
    }
    
    subscript (specifier: Specifier) -> Plugin.Type {
        get {
            return pluginMap[specifier]!
        }
    }
    
    private func resolve(specifierPattern: SpecifierPattern, origins: [Specifier]) throws -> DependencyTree {
        let matchingSpecifiers = specifiers.filter {
           specifierPattern.matches(specifier: $0)
        }
        guard !matchingSpecifiers.isEmpty else {
            throw Error.resolveFailure("No matching specifiers for \(specifierPattern)")
        }
        let resolvables = matchingSpecifiers.compactMap {
            try? resolve(specifier: $0, origins: origins)
        }
        guard !resolvables.isEmpty else {
            throw Error.resolveFailure("Can't resolve dependencies for \(specifierPattern)")
        }
        return resolvables.sorted(by: { $0.specifier.version < $1.specifier.version }).last!
    }
    
    private func resolve(specifier: Specifier, origins: [Specifier]) throws -> DependencyTree {
        guard specifiers.contains(specifier) else {
            throw Error.resolveFailure("Specifier \(specifier) doesn't exist")
        }
        if origins.contains(specifier) {
            throw Error.circularDependency(origins)
        }
        guard let pluginType = pluginMap[specifier] else {
            throw Error.resolveFailure("Failed to find plugin for specifier \(specifier)")
        }
        if pluginType.dependencies.isEmpty {
            return .leaf(specifier)
        }
        let (requiredDeps, optionalDeps) = pluginType.dependencies.divide { $0.isRequired }
        let resolvedRequiredDeps = try requiredDeps.map {
            try resolve(specifierPattern: $0.specifierPattern, origins: origins + [specifier])
        }
        let resolvedOptionalDeps = optionalDeps.compactMap {
            try? resolve(specifierPattern: $0.specifierPattern, origins: origins + [specifier])
        }
        return .node(specifier, resolvedRequiredDeps + resolvedOptionalDeps)
    }
    
    func makePluginMap(pluginTypes: [Plugin.Type], aliases: [String: Plugin.Type]) throws {
        try pluginTypes.forEach { type in
            let alias = aliases.first(where: { key, value in value == type })?.key
            guard let specifier = type.specifier.aliased(with: alias) else {
                throw Error.initializationFailure("Bad alias for \(type): \(alias ?? "")")
            }
            
            if let otherType = pluginMap[specifier] {
                throw Error.nameDuplication(type, otherType)
            }
            pluginMap[specifier] = type
            specifiers.append(specifier)
        }
    }
}

fileprivate extension Array {
    func divide(by predicate: (Element) -> Bool) -> ([Element], [Element]) {
        var positive = [Element]()
        var negative = [Element]()
        for element in self {
            if predicate(element) {
                positive.append(element)
            } else {
                negative.append(element)
            }
        }
        return (positive, negative)
    }
    
 
}

fileprivate extension Array where Element: Hashable {
    func withoutDuplicates() -> [Element] {
        var found = Set<Element>()
        var result = [Element]()
        for element in self {
            if found.contains(element) { continue }
            result.append(element)
            found.insert(element)
        }
        return result
    }
}
