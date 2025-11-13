//
//  ExperimentValue+Codable.swift
//  Statsig Test
//
//  Created by Olivier Butler on 12/11/2025.
//

import Foundation

// Types that wish to decode heterogeneous Statsig dictionaries into strongly typed
// domain models can conform to this protocol.  By default, any type which is both
// `Decodable` and `ExperimentValue` will gain the implementation below, but custom
// types can override the behaviour (for example to provide a bespoke `JSONDecoder`).
public protocol ExperimentValueCodable: ExperimentValue {
    /// Override to customise decoding behaviour (e.g. different key strategies).
    static var statsigDecoder: JSONDecoder { get }

    /// Attempt to decode the Statsig payload into `Self`.
    /// - Parameter dictionary: The `[String: Any]` representation fetched from Statsig.
    /// - Returns: A decoded value when possible.
    static func decode(fromStatsig dictionary: [String: Any]) -> Self?
}

public extension ExperimentValueCodable {
    static var statsigDecoder: JSONDecoder { JSONDecoder() }
}

public extension ExperimentValueCodable where Self: Decodable {
    static func decode(fromStatsig dictionary: [String: Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dictionary) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return nil
        }
        return try? statsigDecoder.decode(Self.self, from: data)
    }
}
