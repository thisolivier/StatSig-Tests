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
