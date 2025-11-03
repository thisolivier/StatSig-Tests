//
//  ContentView.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

struct SpamInitilisationReadinessTests: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var lines = [String]()

    var body: some View {
        VStack {
            Button("Stop Spam") {
                Task { await statSig.stopSpam() }
            }
            Button("Reinitialise") {
                Task { try? await statSig.initialise() }
            }
            Text(ready)
            List(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
                .listStyle(.plain)
        }
        .task {
            do {
                await statSig.spamGateCheck()
                try await statSig.initialise()
                ready = "Hell Yeah"
            } catch {
                ready = "Unknown Error"
            }
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
    SpamInitilisationReadinessTests()
}
