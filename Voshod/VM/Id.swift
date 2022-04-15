//
//  Id.swift
//  Voshod
//
//  Created by Alexander Doloz on 13.04.2022.
//

import Foundation

public typealias Id = Int

enum IdRealm: CustomStringConvertible {
    case plugins, vms
    
    var description: String {
        switch self {
        case .plugins: return "plugins"
        case .vms: return "VMs"
        }
    }
}

struct IdStorage {
    private var range = 0..<1
    private var freed = Set<Int>()
    
    mutating func claimId() -> Id {
        if let id = freed.popFirst() {
            return id
        }
        let id = range.upperBound - 1
        range = range.lowerBound..<(range.upperBound + 1)
        return id
    }
    
    func isClaimed(id: Id) -> Bool {
        return range.contains(id) && !freed.contains(id)
    }
    
    mutating func free(id: Id) {
        freed.insert(id)
    }
}

