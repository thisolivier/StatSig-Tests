//
//  StatSigServiceEnvironmentKey.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

private struct StatSigServiceKey: EnvironmentKey {
    static var defaultValue: StatSigTestable = NoopStatsig()
}

public extension EnvironmentValues {
    var statSigService: any StatSigTestable {
        get { self[StatSigServiceKey.self] }
        set {self[StatSigServiceKey.self] = newValue }
    }
}

public actor NoopStatsig: StatSigTestable {
    public var isReady: Bool = false
    public func initialise() async throws {}
    public func check(gate: String) async -> Bool { false }
    public func get(experiment: String) async -> [String : Any] { [:] }
    public func spamGateCheck() async {}
    public func stopSpam() async {}
    public func logStream() async -> AsyncStream<String> {
        AsyncStream<String>(){_ in}
    }
}
