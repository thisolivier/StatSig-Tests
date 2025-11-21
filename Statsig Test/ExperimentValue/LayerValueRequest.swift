//
//  ExperimentValueRequest.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

// Used to make a structured request for a layer
public struct LayerValueRequest<T: ExperimentValue> {
    let layerName: String
    let valueKey: String
    let defaultValue: T
}

// An alternative which offloads the mapping responsability to the caller
public struct CustomLayerValueRequest<T> {
    let layerName: String
    let valueKey: String
    let defaultValue: T
    private let handler: (Layer, String, T) -> T

    init(layerName: String, valueKey: String, defaultValue: T, handler: @escaping (Layer, String, T) -> T) {
        self.layerName = layerName
        self.valueKey = valueKey
        self.defaultValue = defaultValue
        self.handler = handler
    }

    func executeHandler(_ layer: Layer) -> T {
        return handler(layer, valueKey, defaultValue)
    }
}
