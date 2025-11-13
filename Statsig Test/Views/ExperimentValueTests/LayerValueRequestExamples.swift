//
//  LayerValueRequestExamples.swift
//  Statsig Test
//
//  Created by Olivier Butler on 12/11/2025.
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

struct Layers {
    static func string() -> LayerValueRequest<String> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "dragons",
            defaultValue: "FAIL"
        )
    }

    static func limitedChaos() -> LayerValueRequest<Dictionary<String, [Int]>> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "limitedChaos",
            defaultValue: ["FAIL": [0]]
        )
    }

    static func seriousChaos() -> LayerValueRequest<ChaoticValue> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "seriousChaos",
            defaultValue: .init(hereWeGo: .init(nestedArray: ["FAIL"], nestedNumber: 0), normality: false)
        )
    }

    static func tools() -> LayerValueRequest<[String]> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "tools",
            defaultValue: ["FAIL"]
        )
    }
}
