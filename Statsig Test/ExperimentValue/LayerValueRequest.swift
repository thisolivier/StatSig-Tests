//
//  ExperimentValueRequest.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation

public struct LayerValueRequest<T: ExperimentValue> {
    let layerName: String
    let valueKey: String
    let defaultValue: T
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

    static func seriousChaos() -> LayerValueRequest<Dictionary<String, ExperimentValue>> {
        return LayerValueRequest(
            layerName: "example_layer",
            valueKey: "seriousChaos",
            defaultValue: ["FAIL": true]
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
