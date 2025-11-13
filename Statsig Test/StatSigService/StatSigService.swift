//
//  StatSigProvider.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import Foundation
import Statsig

public typealias StatSigTestable = StatSigProvidable & SpamCheckable

// Note, this is designed as a working scratchpad to test various theories, not a stable production facing interface.

public protocol StatSigProvidable {
    var isReady: Bool { get async }
    func initialise(_: StatSigInitArgs) async throws
    func check(gate: String) async -> Bool
    func get(experiment: String) async -> [String: Any]
    func getValue <T: ExperimentValue>(
        valueRequest: LayerValueRequest<T>
    ) async -> T
    func logStream() async -> AsyncStream<String>
}

extension StatSigProvidable {
    func initialise(_ args: StatSigInitArgs = .normal) async throws {
        try await initialise(args)
    }
}

public protocol SpamCheckable {
    func spamGateCheck() async -> Void
    func stopSpam() async -> Void
}

public struct StatSigInitArgs {
    public var logging: Bool
    public var userId: String?

    public static let normal: Self = .init(logging: true, userId: nil)
}

public actor StatSigService: StatSigProvidable {

    private var ready: Bool = false
    private var oldValue: Bool?
    private var userId: String

    private let sdkKey: String
    private let now: Date = Date()

    private var logs: [String] = []
    private var continuation: AsyncStream<String>.Continuation?
    private var task: Task<Void, Never>?
    var continueSpamming: Bool = true

    public init(
        sdkKey: String = "client-UTgfra8reyCWYvWrgs2zIVpLIRIRDfu1SXysakeq4je",
        userId: String = "beansbeans12345678" // Static ID used as default
    ) {
        self.sdkKey = sdkKey
        self.userId = userId
    }

    public func initialise(_ args: StatSigInitArgs = .normal) async throws {
        //guard !ready else { return }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            let options = StatsigOptions(
                autoValueUpdateIntervalSec: 15,
                overrideStableID: args.userId ?? self.userId,
                eventLoggingEnabled: args.logging
            )
            let user = StatsigUser(userID: args.userId ?? self.userId)
            continuation?.yield("RELOADING, \(Date().timeIntervalSince(self.now))")
            self.oldValue = nil
            Statsig.shutdown()
            Statsig.initialize(
                sdkKey: sdkKey,
                user: user,
                options: options
            ) { error in
                if let error = error {
                    cont.resume(throwing: error)
                } else {
                    self.oldValue = nil
                    self.continuation?.yield("READY, \(Date().timeIntervalSince(self.now))")
                    self.ready = true
                    cont.resume()
                }
            }
        }
    }

    public func setLogging(_ logging: Bool) async throws {
        Statsig.updateOptions(eventLoggingEnabled: logging)
        Statsig.flush()
    }

    public func check(gate: String = "myfirsttestfeaturegate") async -> Bool {
        return Statsig.checkGate(gate)
    }

    public func get(experiment: String = "myfirsttestexperiment") async -> [String: Any] {
        return Statsig.getExperiment(experiment).value
    }

    public func getValue <T: ExperimentValue>(
        valueRequest: LayerValueRequest<T>
    ) async -> T {
        return await GetValue(
            experimentName: valueRequest.layerName,
            key: valueRequest.valueKey,
            defaultValue: valueRequest.defaultValue
        )
    }


    public var isReady: Bool { ready }

    // Expose an AsyncStream of log lines
    public func logStream() async -> AsyncStream<String> {
        AsyncStream { continuation in
            // keep the continuation so we can yield future lines
            self.continuation = continuation
            // optionally replay existing lines to a new subscriber
        }
    }
}

extension StatSigService: SpamCheckable {
    public func spamGateCheck() async {
        task = Task {
            await self.spamLoop()
        }
    }

    private func spamLoop() async {
        while self.continueSpamming {
            let result = await check()
            if oldValue != result {
                let message = "The value of myfirst is: \(result.description), Time: \(Date().timeIntervalSince(self.now))"
                print(message)
                continuation?.yield(message)
            }
            oldValue = result
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    public func stopSpam() {
        continueSpamming = false
        continuation?.finish()
        task?.cancel()
        task = nil
    }
}
