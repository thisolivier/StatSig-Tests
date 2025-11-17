//
//  GetValueHelper.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

class GetValueHelper {

    public func getValue<T: ExperimentValue>(
        experimentName: String,
        key: String,
        defaultValue: T
    ) -> T {
        let layer = Statsig.getLayer(experimentName)

        // Codable experiment values – attempt to decode heterogeneous dictionaries first.
        if let codable: T = handleCodable(layer: layer, key: key) { return codable }

        // Scalars – let Statsig do typed fetch + defaulting (no force unwraps).
        if let scalar: T = handleScalar(layer: layer, key: key) { return scalar }

        // Homogeneous arrays – supported concrete element types only.
        if let scalarArray: T = handleArrayOfScalar(
            layer: layer,
            key: key
        ) { return scalarArray }

        // Array of codable objects
        if let arrayOfCodable: T = handleArrayOfCodable(
            layer: layer,
            key: key,
            defaultValue: defaultValue
        ) { return arrayOfCodable }

        // Heterogeneous dictionary (recommend not supporting)
        if let dictionary: T = handleComplexDictionary(
            layer: layer,
            key: key,
            defaultValue: defaultValue
        ) { return dictionary }

        return defaultValue
    }
}

extension GetValueHelper {
    private func handleScalar<T: ExperimentValue>(
        layer: Layer,
        key: String
    ) -> T? {
        switch T.self {
        case is String.Type:
            let v: String? = layer.getValue(forKey: key)
            return v as? T
        case is Int.Type:
            let v: Int? = layer.getValue(forKey: key)
            return v as? T
        case is Double.Type:
            let v: Double? = layer.getValue(forKey: key)
            return v as? T
        case is Bool.Type:
            let v: Bool? = layer.getValue(forKey: key)
            return v as? T
        default:
            return nil
        }
    }

    private func handleArrayOfScalar<T: ExperimentValue>(
        layer: Layer,
        key: String
    ) -> T? {
        // Helper for [E]
        func get1DArray<E: ExperimentValue>(_ type: E.Type) -> T? {
            let v: [E]? = layer.getValue(forKey: key)
            return v as? T
        }

        // Helper for [[E]]
        func get2DArray<E: ExperimentValue>(_ type: E.Type) -> T? {
            let v: [[E]]? = layer.getValue(forKey: key)
            return v as? T
        }

        switch T.self {
        // 1D arrays
        case is [String].Type:
            return get1DArray(String.self)
        case is [Int].Type:
            return get1DArray(Int.self)
        case is [Double].Type:
            return get1DArray(Double.self)
        case is [Bool].Type:
            return get1DArray(Bool.self)

        // 2D/nested arrays
        case is [[String]].Type:
            return get2DArray(String.self)
        case is [[Int]].Type:
            return get2DArray(Int.self)
        case is [[Double]].Type:
            return get2DArray(Double.self)
        case is [[Bool]].Type:
            return get2DArray(Bool.self)
        default:
            return nil
        }
    }

    private func handleCodable<T: ExperimentValue>(
        layer: Layer,
        key: String
    ) -> T? {
        guard
            let codableType = T.self as? ExperimentValueCodable.Type,
            let raw: [String: Any] = layer.getValue(forKey: key),
            let decoded = codableType.decode(fromStatsig: raw) as? T
        else {
            return nil
        }
        return decoded
    }

    func handleArrayOfCodable<T: ExperimentValue>(
        layer: Layer,
        key: String,
        defaultValue: T // Needed to establish concrete type to decode
    ) -> T? {
        guard
            let defaultAsArray = defaultValue as? [any ExperimentValueCodable],
            let raw: [[String: Any]] = layer.getValue(forKey: key)
        else {
            return nil
        }

        // If the default is empty, we don't know what concrete type to decode to.
        guard let first = defaultAsArray.first else {
            // Obviously this isn't production code.
            fatalError("Empty arrays of as default values when dealing with arrays of codable objects are not supported.")
        }
        let elementType = type(of: first)

        // Decode and return
        let newArray: [any ExperimentValueCodable] = raw.compactMap { item in
            elementType.decode(fromStatsig: item)
        }
        return (newArray as? T)
    }

    // I do not like this approach
    func handleComplexDictionary<T: ExperimentValue>(
        layer: Layer,
        key: String,
        defaultValue: T 
    ) -> T? {
        // Would recommend deprecating this in favour of Codable types.
        guard let _ = defaultValue as? [String: any ExperimentValue] else {
            return nil
        }
        // Fetch Statsig's object [String: Any] and bridge to [String: any ExperimentValue]
        guard
            let raw: [String: Any]  = layer.getValue(forKey: key),
            let bridged = BridgeEVObject(raw),
            let result = bridged as? T
        else {
            return nil
        }
        return result
    }
}
