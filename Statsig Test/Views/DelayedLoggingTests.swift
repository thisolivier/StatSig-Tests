//
//  ContentView.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

// Results
// - Logs don't happen with logging disabled [Y]
// - Logs do happen with logging enabled [Y]
// - Logs which happen while disabled are lost if enabled with a different ID [Y]
// - Logs which happen while disabled are replayed if enabled with the same ID [Y]
// - Replayed logs record the original time of decision making [Y]
// - Logs during re-init with new user [N - provides fallback & the use of fallback is recorded when logging is enabled]
// - Logs when called during re-init (from log disabled to log enabled) with same user when [Y - though noted as value coming from cache]
// - Logs when called during re-init (keeping logging disabled) with same user and later enabling logging [Y - though noted as value coming from cache]

struct DelayedLoggingTests: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var lines = [String]()
    @State private var customId = ""
    @State private var experimentValue = "--"
    @State private var isLogging = false

    var body: some View {
        VStack {
            Text(ready)
            Toggle("Is Logging", isOn: $isLogging)
            Text("Experiment Value: \(experimentValue)")
            TextField("Custom ID", text: $customId)
            Spacer()
            Button("Get Experiment Value") {
                Task {
                    self.experimentValue = (await statSig
                        .get(
                            experiment: "myfirsttestexperiment"
                        )["theResult"] as? String ?? "No Matching Value") + " - \(Date().timeIntervalSince1970)"
                }
            }
            Button("Reinitialise") {
                Task {
                    ready = "Reinitialising…"
                    try? await statSig.initialise(.init(
                        logging: isLogging,
                        userId: customId == "" ? nil : customId
                    ))
                    ready = "StatSig is Ready"
                }
            }
            Button("Reinitialise & Query During Init") {
                Task {
                    await MainActor.run {
                        lines.removeAll()
                        ready = "Reinitialising…"
                    }

                    // Kick off initialisation, but don't await it yet
                    let initTask = Task {
                        try await statSig.initialise(.init(
                            logging: isLogging,
                            userId: customId.isEmpty ? nil : customId
                        ))
                    }

                    // Wait a brief moment to ensure init is underway
                    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms

                    // Single get() call during init
                    let valDuringInit = await statSig
                        .get(experiment: "myfirsttestexperiment")["theResult"] as? String
                        ?? "No Matching Value"
                    let stamp = String(format: "%.3f", Date().timeIntervalSince1970)
                    await MainActor.run {
                        self.experimentValue = "\(valDuringInit) - \(stamp)"
                        self.lines.append("[during init] \(stamp) get -> \(valDuringInit)")
                    }

                    // Now wait for init to complete
                    do {
                        try await initTask.value
                        await MainActor.run {
                            ready = "StatSig is Ready"
                            lines.append("[done] \(stamp) init complete")
                        }
                    } catch {
                        await MainActor.run {
                            ready = "Init failed"
                            lines.append("[error] \(stamp) \(error.localizedDescription)")
                        }
                    }
                }
            }

            List(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
                .listStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    SpamInitilisationReadinessTests()
}
