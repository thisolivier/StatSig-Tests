//
//  ContentView.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

struct DelayedLoggingTests: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var lines = [String]()

    var body: some View {
        VStack {
            Button("Get Experiment Value") {
                Task {
                    // TODO: Get experiment valye
                    await statSig.stopSpam()
                }
            }
            // TODO: Add toggle to set event logging
            // TODO: Add field to set user ID manually
            Button("Reinitialise") {
                Task {
                    // TODO: Expose a way to set ID and logging status
                    ready = "Not Yet Ready"
                    try? await statSig.initialise()
                }
            }
            Text(ready)
            List(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
                .listStyle(.plain)
        }
        .task {
            do {
                await statSig.spamGateCheck()
                try await statSig.initialise()
                ready = "StatSig is Ready"
            } catch {
                ready = "StatSig Init: Unknown Error"
            }
        }
        .padding()
    }
}

#Preview {
    SpamInitilisationReadinessTests()
}
