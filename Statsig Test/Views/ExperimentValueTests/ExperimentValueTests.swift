//
//  ExperimentValueTests.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import SwiftUI

struct ExperimentValueTests: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var isLogging = false
    @State private var customId = ""

    // Results
    @State private var stringResult: String = "—"
    @State private var limitedChaosResult: String = "—"
    @State private var seriousChaosResult: String = "—"
    @State private var toolsResult: String = "—"

    @State private var lines: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ready)
            Toggle("Is Logging", isOn: $isLogging)
            TextField("Custom ID", text: $customId)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)

            Divider()

            // Display the latest results
            Group {
                LabeledContent("Layers.string()") { Text(stringResult).font(.system(.body, design: .monospaced)) }
                LabeledContent("Layers.limitedChaos()") { Text(limitedChaosResult).font(.system(.body, design: .monospaced)) }
                LabeledContent("Layers.seriousChaos()") { Text(seriousChaosResult).font(.system(.body, design: .monospaced)) }
                LabeledContent("Layers.tools()") { Text(toolsResult).font(.system(.body, design: .monospaced)) }
            }

            Divider()

            // Action buttons
            VStack(alignment: .leading, spacing: 8) {
                Button("Get Layers.string()") {
                    Task {
                        let v: String = await statSig.getValue(valueRequest: Layers.string())
                        let stamp = ts()
                        stringResult = "\(v)  @\(stamp)"
                        append("[string] \(stamp) -> \(v)")
                    }
                }

                Button("Get Layers.limitedChaos()") {
                    Task {
                        let v: [String: ExperimentValue] = await statSig.getValue(valueRequest: Layers.limitedChaos())
                        let s = formatDict(v)
                        let stamp = ts()
                        limitedChaosResult = "\(s)  @\(stamp)"
                        append("[limitedChaos] \(stamp) -> \(s)")
                    }
                }

                Button("Get Layers.seriousChaos()") {
                    Task {
                        let v: ChaoticValue = await statSig.getValue(valueRequest: Layers.seriousChaos())
                        let s = String(describing: v)
                        let stamp = ts()
                        seriousChaosResult = "\(s)  @\(stamp)"
                        append("[seriousChaos] \(stamp) -> \(s)")
                    }
                }

                Button("Get Layers.tools()") {
                    Task {
                        let v: [String] = await statSig.getValue(valueRequest: Layers.tools())
                        let s = "[\(v.joined(separator: ", "))]"
                        let stamp = ts()
                        toolsResult = "\(s)  @\(stamp)"
                        append("[tools] \(stamp) -> \(s)")
                    }
                }

                Button("Reinitialise") {
                    Task {
                        await MainActor.run { ready = "Reinitialising…" }
                        do {
                            try await statSig.initialise(.init(
                                logging: isLogging,
                                userId: customId.isEmpty ? nil : customId
                            ))
                            await MainActor.run { ready = "StatSig is Ready" }
                        } catch {
                            await MainActor.run { ready = "Init failed: \(error.localizedDescription)" }
                        }
                    }
                }
            }

            Divider()

            List(lines, id: \.self) { Text($0).font(.system(.footnote, design: .monospaced)) }
                .listStyle(.plain)
        }
        .padding()
    }

    // MARK: - Helpers

    private func ts() -> String {
        String(format: "%.3f", Date().timeIntervalSince1970)
    }

    private func append(_ s: String) {
        lines.append(s)
    }

    private func formatDict(_ dict: [String: ExperimentValue]) -> String {
        let body = dict
            .map { key, val in "\"\(key)\": \(String(describing: val))" }
            .sorted()
            .joined(separator: ", ")
        return "{ \(body) }"
    }
}

#Preview {
    ExperimentValueTests()
}
