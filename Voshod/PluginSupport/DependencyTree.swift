//
//  DependencyTree.swift
//  Voshod
//
//  Created by Alexander Doloz on 20.04.2022.
//

import Foundation

enum DependencyTree {
    case leaf(Specifier)
    case node(Specifier, [DependencyTree])
    
    var specifier: Specifier {
        switch self {
        case .leaf(let specifier): return specifier
        case .node(let specifier, _): return specifier
        }
    }
    
    func iterate(with closure: (_ specifier: Specifier, _ isLeaf: Bool) -> Void) {
        switch self {
        case .leaf(let specifier): closure(specifier, true)
        case .node(let specifier, let trees):
            closure(specifier, false)
            trees.forEach {
                $0.iterate(with: closure)
            }
        }
    }
    
//    func iterateFromLeaves(with closure: ()
}
