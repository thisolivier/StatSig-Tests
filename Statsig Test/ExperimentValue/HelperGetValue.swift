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
    if let codableType = T.self as? ExperimentValueCodable.Type {
        let candidate: [String: Any]? = layer.getValue(forKey: key)
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
    if let defaultAsArray = defaultValue as? [any ExperimentValueCodable] {
        guard
            let raw: [[String: Any]] = layer.getValue(forKey: key)
        else {
            return defaultValue
        }

        // If the default is empty, we don't know what concrete type to decode to.
        guard let first = defaultAsArray.first else {
            return defaultValue // This is a bad fallback - we need a default value to work with.
        }

        let elementType = type(of: first)   // elementType: any ExperimentValueCodable.Type

        // Decode each dictionary into that element type.
        let newArray: [any ExperimentValueCodable] = raw.compactMap { item in
            elementType.decode(fromStatsig: item)
        }

        // Coerce back to T if possible; otherwise fall back to default.
        return (newArray as? T) ?? defaultValue
    }

    // Heterogeneous dictionary – fetch Statsig's object and bridge to [String: any ExperimentValue].
    // Would recommend deprecating this in favour of Codable types.
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
