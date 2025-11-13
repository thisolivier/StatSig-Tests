//
//  HomeView.swift
//  Statsig Test
//
//  Created by Olivier Butler on 03/11/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tests of Statsig SDK").font(.title)
                Button("Spam Initialisation Tests") { path.append(Route.SpamInit) }
                Button("Delayed Login Tests") { path.append(Route.DelayedLogging) }
                Text("Tests of simple interface ontop of StatSig").font(.title)
                Button("Value Conversion Tests") { path.append(Route.ExperimentValue) }
                Text("The value conversion tests are checking we can use a generic-based getter to pull scalar values, arrays, dictionaries and objects. See the ExperimentValue directory and readme for more details.")
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            // map route values to destination views
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .SpamInit: TestReadinessView()
                case .DelayedLogging: TestDelayedLoggingView()
                case .ExperimentValue: TestExperimentValueView()
                }
            }
        }
    }
}
