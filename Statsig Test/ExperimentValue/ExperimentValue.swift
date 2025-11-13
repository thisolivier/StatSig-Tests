//
//  ExperimentValue.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation

public protocol ExperimentValue {}

extension String: ExperimentValue {}
extension Int: ExperimentValue {}
extension Double: ExperimentValue {}
extension Bool: ExperimentValue {}

// Homogeneous arrays only
extension Array: ExperimentValue where Element: ExperimentValue {}

// Homogenious dictionary supported: directly declare the conformance
extension Dictionary: ExperimentValue where Key == String, Value: ExperimentValue {}


// Types that wish to decode heterogeneous Statsig dictionaries into strongly typed
// domain models can conform to this protocol.  By default, any type which is both
// `Decodable` and `ExperimentValue` will gain the implementation below, but custom
// types can override the behaviour (for example to provide a bespoke `JSONDecoder`).
public protocol StatsigCodableExperimentValue: ExperimentValue {
    /// Override to customise decoding behaviour (e.g. different key strategies).
    static var statsigDecoder: JSONDecoder { get }

    /// Attempt to decode the Statsig payload into `Self`.
    /// - Parameter dictionary: The `[String: Any]` representation fetched from Statsig.
    /// - Returns: A decoded value when possible.
    static func decode(fromStatsig dictionary: [String: Any]) -> Self?
}

public extension StatsigCodableExperimentValue {
    static var statsigDecoder: JSONDecoder { JSONDecoder() }
}

public extension StatsigCodableExperimentValue where Self: Decodable {
    static func decode(fromStatsig dictionary: [String: Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dictionary) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return nil
        }
        return try? statsigDecoder.decode(Self.self, from: data)
    }
}
