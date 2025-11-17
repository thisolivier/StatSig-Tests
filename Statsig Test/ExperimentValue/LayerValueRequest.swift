//
//  ExperimentValueRequest.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import Foundation
import Statsig

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
    let handler: (Layer, String, T) -> T
}
