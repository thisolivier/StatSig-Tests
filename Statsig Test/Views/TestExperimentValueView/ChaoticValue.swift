//
//  LayerRequestSupportingTypes.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/11/2025.
//

import Foundation

public struct ChaoticValue: Codable, ExperimentValueCodable {
    public struct NestedObject: Codable, ExperimentValueCodable {
        var nestedArray: [String]
        var nestedNumber: Float
    }

    var hereWeGo: NestedObject
    var normality: Bool
}
