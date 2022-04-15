//
//  VM.Value.swift
//  Voshod
//
//  Created by Alexander Doloz on 11.04.2022.
//

import Foundation
import LuaJIT

extension VM {
    public enum Value: Equatable {
        case `nil`
        case int(Int)
        case double(Double)
        case bool(Bool)
        case string(String)
        case array([Value])
        case dictionary([String: Value])
        case pointer(UnsafeMutableRawPointer)
        
        init(object: AnyObject) {
            let pointer = Unmanaged.passUnretained(object).toOpaque()
            self = .pointer(pointer)
        }
        
        // TODO: Getters
        public func toInt() -> Int? {
            switch self {
            case .int(let i): return i
            default: return nil
            }
        }
        public func toDouble() -> Double? {
            switch self {
            case .double(let d): return d
            default: return nil
            }
        }
        var bool: Bool? { nil }
        var string: String? { nil }
        var array: [Value]? { nil }
        public var dictionary: [String: Value]? {
            switch self {
            case .dictionary(let dict): return dict
            default: return nil
            }
        }
        var pointer: UnsafeMutableRawPointer? { nil }
    }
}

