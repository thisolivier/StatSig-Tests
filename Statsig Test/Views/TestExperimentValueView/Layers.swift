//
//  LayerValueRequestExamples.swift
//  Statsig Test
//
//  Created by Olivier Butler on 12/11/2025.
//

// See ExperimentValue/README.md for an explanation of what's going on here

import Foundation

struct Layers {

    // MARK: - Scalars

    static func string() -> LayerValueRequest<String> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "dragons",
            defaultValue: "FAIL"
        )
    }

    // MARK: - Arrays

    static func tools() -> LayerValueRequest<[String]> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "tools",
            defaultValue: ["FAIL"]
        )
    }

    static func emptyArray() -> LayerValueRequest<[String]> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "emptyArray",
            defaultValue: ["FAIL"]
        )
    }

    // MARK: - Dictionary

    static func limitedChaos() -> LayerValueRequest<Dictionary<String, [Int]>> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "limitedChaos",
            defaultValue: ["FAIL": [0]]
        )
    }

    // MARK: - Codable types

    static func seriousChaos() -> LayerValueRequest<ChaoticValue> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "seriousChaos",
            defaultValue: .init(hereWeGo: .init(nestedArray: ["FAIL"], nestedNumber: 0), normality: false)
        )
    }

    static func objectInArray() -> LayerValueRequest<[ArrayElementValue]> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "arrayOfObjects",
            defaultValue: [.init(name: "FAIL", hand: [])]
        )
    }
}
