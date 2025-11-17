//
//  ExperimentValueTests.swift
//  Statsig Test
//
//  Created by Olivier Butler on 11/11/2025.
//

import SwiftUI

struct TestExperimentValueView: View {
    @Environment(\.statSigService) private var statSig
    @State private var ready = "Not Yet Ready"
    @State private var customId = ""

    // Results
    @State private var stringResult: String = "—"
    @State private var limitedChaosResult: String = "—"
    @State private var seriousChaosResult: String = "—"
    @State private var toolsResult: String = "—"
    @State private var emptyArrayResult: String = "-"
    @State private var objectInArrResult: String = "-"
    @State private var customHandlerResult: String = "-"

    @State private var lines: [String] = []

    var body: some View {
        ScrollView(){
            VStack(alignment: .leading, spacing: 12) {
                Text(ready)
                TextField("Custom ID", text: $customId)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                Button("Reinitialise") {
                    Task {
                        await MainActor.run { ready = "Reinitialising…" }
                        do {
                            try await statSig.initialise(.init(
                                logging: true,
                                userId: customId.isEmpty ? nil : customId
                            ))
                            await MainActor.run { ready = "StatSig is Ready" }
                        } catch {
                            await MainActor.run { ready = "Init failed: \(error.localizedDescription)" }
                        }
                    }
                }
                Divider()

                // Display the latest results
                Group {
                    FlexibleLabeledContent(label: "Layers.string()") { Text(stringResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label: "Layers.limitedChaos()") { Text(limitedChaosResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label:"Layers.seriousChaos()") { Text(seriousChaosResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label:"Layers.tools()") { Text(toolsResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label:"Layers.emptyArray()") { Text(emptyArrayResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label:"Layers.objectInArray()") { Text(objectInArrResult).font(.system(.body, design: .monospaced)) }
                    FlexibleLabeledContent(label:"Layers.customHandler()") { Text(customHandlerResult).font(.system(.body, design: .monospaced)) }
                }

                Divider()

                // Action buttons
                VStack(alignment: .leading, spacing: 8) {
                    Button("Get Layers.string()") {
                        Task {
                            let v: String = await statSig.getValue(valueRequest: Layers.string())
                            let stamp = ts()
                            stringResult = "\(v)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.limitedChaos()") {
                        Task {
                            let v: [String: ExperimentValue] = await statSig.getValue(valueRequest: Layers.limitedChaos())
                            let s = formatDict(v)
                            let stamp = ts()
                            limitedChaosResult = "\(s)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.seriousChaos()") {
                        Task {
                            let v: ChaoticValue = await statSig.getValue(valueRequest: Layers.seriousChaos())
                            let s = String(describing: v)
                            let stamp = ts()
                            seriousChaosResult = "\(s)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.tools()") {
                        Task {
                            let v: [String] = await statSig.getValue(valueRequest: Layers.tools())
                            let s = "[\(v.joined(separator: ", "))]"
                            let stamp = ts()
                            toolsResult = "\(s)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.emptyArray()") {
                        Task {
                            let v: [String] = await statSig.getValue(valueRequest: Layers.emptyArray())
                            let stamp = ts()
                            emptyArrayResult = "\(v)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.objectInArray()") {
                        Task {
                            let v: [ArrayElementValue] = await statSig.getValue(valueRequest: Layers.objectInArray())
                            let s = String(describing: v)
                            let stamp = ts()
                            objectInArrResult = "\(s)  @\(stamp)"
                        }
                    }

                    Button("Get Layers.customHandler()") {
                        Task {
                            let v: [ArrayElementValue] = await statSig.getValue(valueRequest: Layers.customHandler())
                            let s = String(describing: v)
                            let stamp = ts()
                            customHandlerResult = "\(s)  @\(stamp)"
                        }
                    }
                }
            }
            .padding()
        }.onAppear(){
            Task {
                await MainActor.run { ready = "Reinitialising…" }
                do {
                    try await statSig.initialise(.init(
                        logging: true,
                        userId: customId.isEmpty ? nil : customId
                    ))
                    await MainActor.run { ready = "StatSig is Ready" }
                } catch {
                    await MainActor.run { ready = "Init failed: \(error.localizedDescription)" }
                }
            }
        }
    }

    // MARK: - Helpers

    private func ts() -> String {
        String(format: "%.3f", Date().timeIntervalSince1970)
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
    TestExperimentValueView()
}
