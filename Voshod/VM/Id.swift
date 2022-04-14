//
//  Id.swift
//  Voshod
//
//  Created by Alexander Doloz on 13.04.2022.
//

import Foundation

typealias Id = Int

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
    private var ids = Set<Id>()
    
    init() {
        
    }
    
    mutating func claimId() throws -> Id {
        return 0
    }
    
    func isClaimed(id: Id) -> Bool {
        false
    }
    
    mutating func free(id: Id) {
        
    }
}

