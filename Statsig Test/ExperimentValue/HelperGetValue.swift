//
//  GetValueHelper.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

public func GetValue<T: ExperimentValue>(
    experimentName: String,
    key: String,
    defaultValue: T
) async -> T {
    let layer = Statsig.getLayer(experimentName)

    // Codable experiment values – attempt to decode heterogeneous dictionaries first.
    if let codableType = T.self as? StatsigCodableExperimentValue.Type {
        var candidate = layer.getValue(forKey: key) as? [String: Any]
        if candidate == nil {
            candidate = layer.getValue(forKey: key, defaultValue: [:]) as? [String: Any]
        }
        if let raw = candidate,
           let decoded = codableType.decode(fromStatsig: raw) as? T {
            return decoded
        }
    }

    // Scalars – let Statsig do typed fetch + defaulting (no force unwraps).
    if T.self == String.self {
        let def = (defaultValue as? String)!
        let v: String = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == Int.self {
        let def = (defaultValue as? Int)!
        let v: Int = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == Double.self {
        let def = (defaultValue as? Double)!
        let v: Double = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == Bool.self {
        let def = (defaultValue as? Bool)!
        let v: Bool = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }

    // Homogeneous arrays (top-level) – supported concrete element types only.
    if T.self == [String].self {
        let def = (defaultValue as? [String])!
        let v: [String] = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == [Int].self {
        let def = (defaultValue as? [Int])!
        let v: [Int] = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == [Double].self {
        let def = (defaultValue as? [Double])!
        let v: [Double] = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }
    if T.self == [Bool].self {
        let def = (defaultValue as? [Bool])!
        let v: [Bool] = layer.getValue(forKey: key, defaultValue: def)
        return (v as? T) ?? defaultValue
    }

    // Heterogeneous dictionary – fetch Statsig's object and bridge to [String: any ExperimentValue].
    if let _ = defaultValue as? [String: any ExperimentValue] {
        guard
            let raw: [String: Any]  = layer.getValue(forKey: key),
            let bridged = BridgeEVObject(raw),
            let result = bridged as? T
        else {
            return defaultValue
        }
        return result
    }

    // We do not support arrays of dictionaries
    // Should add some check here if no value found.

    return defaultValue
}
