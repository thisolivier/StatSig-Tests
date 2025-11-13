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

