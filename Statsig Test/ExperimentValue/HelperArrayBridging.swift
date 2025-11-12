//
//  HelperArrayBridging.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

// Bridge a Statsig array into a homogeneous ExperimentValue array.
// Infers element type from the first element.
// Rejects empty arrays and any mismatches.
// Nested arrays and arrays of objects not supported.
func BridgeArrayToHomogeneous(
    _ array: [Any]
) -> (any ExperimentValue)? {
    guard let first = array.first else { return nil }

    switch first {
    case is String:
        var out = [String]()
        out.reserveCapacity(array.count)
        for e in array { guard let v = e as? String else { return nil }; out.append(v) }
        return out

    case is Int:
        var out = [Int]()
        out.reserveCapacity(array.count)
        for e in array { guard let v = e as? Int else { return nil }; out.append(v) }
        return out

    case is Double:
        var out = [Double]()
        out.reserveCapacity(array.count)
        for e in array { guard let v = e as? Double else { return nil }; out.append(v) }
        return out

    case is Bool:
        var out = [Bool]()
        out.reserveCapacity(array.count)
        for e in array { guard let v = e as? Bool else { return nil }; out.append(v) }
        return out

    default:
        return nil
    }
}
