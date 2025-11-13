//
//  HelperObjectBridging.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

// Bridge a homogeneous dictionary of Any values into ExperimentValue values recursively.
// Reject mixed-value kinds (e.g., String with Int) and any unsupported kinds.
// Rejects nested objects
func BridgeEVObject(
    _ dict: [String: Any]
) -> [String: any ExperimentValue]? {

    // Empty dictionaries are trivially homogeneous.
    if dict.isEmpty { return [:] }

    enum Kind {
        case string, bool, int, double, array, object
    }

    // Helper to classify an incoming value.
    func classify(_ v: Any) -> Kind? {
        if v is String { return .string }
        if v is Bool   { return .bool }
        if v is Int    { return .int }
        if v is Double { return .double }
        if v is [Any] { return .array }
        if v is [String: Any] { return .object } // Note: Not supported
        return nil
    }

    // Determine the required (homogeneous) kind for this dictionary.
    guard let requiredKind: Kind = {
        for v in dict.values {
            if let k = classify(v) { return k }
            else {
                // Unsupported value kind encountered; consider logging here.
                return nil
            }
        }
        return nil
    }() else {
        // Unsupported or unclassifiable first value; consider logging here.
        return nil
    }

    var out: [String: any ExperimentValue] = .init(minimumCapacity: dict.count)

    // Bridge all entries, enforcing homogeneity by kind.
    for (k, v) in dict {
        guard let knd = classify(v), knd == requiredKind else {
            // Mixed kinds in dictionary; consider logging here.
            return nil
        }

        switch requiredKind {
        case .string:
            guard let s = v as? String else { return nil }
            out[k] = s

        case .bool:
            guard let b = v as? Bool else { return nil }
            out[k] = b

        case .int:
            guard let i = v as? Int else { return nil }
            out[k] = i

        case .double:
            guard let d = v as? Double else { return nil }
            out[k] = d

        case .array:
            guard let arr = v as? [Any],
                  let bridged = BridgeArrayToHomogeneous(arr) else {
                // Array not homogeneous or contains unsupported values; consider logging here.
                return nil
            }
            out[k] = bridged

        case .object:
            // Not supported
            return nil
        }
    }
    return out
}


