//
//  HelperObjectBridging.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

// Bridge a heterogeneous dictionary recursively.
// Reject on any unsupported or mixed-type array values.
func BridgeEVObject(
    _ dict: [String: any StatsigDynamicConfigValue]
) -> [String: any ExperimentValue]? {
    var out: [String: any ExperimentValue] = .init(minimumCapacity: dict.count)

    for (k, v) in dict {
        switch v {
        case let s as String: out[k] = s
        case let b as Bool:   out[k] = b
        case let i as Int:    out[k] = i
        case let d as Double: out[k] = d

        case let arr as [any StatsigDynamicConfigValue]:
            guard let bridged = BridgeArrayToHomogeneous(arr) else { return nil }
            out[k] = bridged

        case let sub as [String: any StatsigDynamicConfigValue]:
            guard let bridged = BridgeEVObject(sub) else { return nil }
            out[k] = bridged

        default:
            // Unsupported type inside object, log error
            return nil
        }
    }
    return out
}

