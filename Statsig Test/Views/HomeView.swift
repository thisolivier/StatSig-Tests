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
            VStack(spacing: 16) {
                Button("Spam Initialisation Tests") { path.append(Route.SpamInit) }
                Button("Delayed Login Tests") { path.append(Route.DelayedLogging) }
                Button("Value Conversion Tests") { path.append(Route.ExperimentValue) }
            }
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
