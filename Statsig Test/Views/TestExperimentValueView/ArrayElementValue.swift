//
//  ArrayExample.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/11/2025.
//

import Foundation

public struct ArrayElementValue: Codable, ExperimentValueCodable {
    var name: String
    var hand: [String]
}
