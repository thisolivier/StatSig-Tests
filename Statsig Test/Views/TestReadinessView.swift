//
//  ContentView.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

// Results
// - Experiment not found if SDK never initialised [Y]
// - Feature gate defaults to off if SDK never initialised [Y]
// - Can continue to spam SDK during init [Y]
// - Once init, will respond correctly to feature gate [Y]
// - On next launch, before init, will respond with last cached value [Y]
// - On next launch, after init, will respond with current value [Y]

struct TestReadinessView: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var lines = [String]()

    var body: some View {
        VStack {
            Button("Start spamming gate check") {
                Task { await statSig.spamGateCheck() }
            }
            Button("Stop Spam") {
                Task { await statSig.stopSpam() }
            }
            Text("When you start spamming the gate check, we check the value of the gate repeatedly at a very short interval. Values which are the same as previous are discarded, new values are logged below.")
            Text("Relaunch the app after first loading StatSig & spam again to see if you get cached values.")
            Button("Initialise/Reinitialise") {
                Task {
                    ready = "Initialising..."
                    do {
                        try await statSig.initialise() // Uses a hardcoded ID
                        ready = "Statsig Ready"
                    } catch {
                        ready = "Statsig Not Ready: Unknown Error"
                    }
                }
            }
            Text(ready)
            List(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
                .listStyle(.plain)
        }
        .task {
            for await line in await statSig.logStream() {
                await MainActor.run {
                    if lines.count > 2000 {
                        lines = ["..."]
                    }
                    lines.append(line)
                }
            }
        }
        .padding()
    }
}

#Preview {
    TestReadinessView()
}
