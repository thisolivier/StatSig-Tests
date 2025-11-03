//
//  Statsig_TestApp.swift
//  Statsig Test
//
//  Created by Olivier Butler on 13/10/2025.
//

import SwiftUI

@main
struct Statsig_TestApp: App {
    private let statSigClient = StatSigService()

    var body: some Scene {
        WindowGroup {
            SpamInitilisationReadinessTests()
                .environment(\.statSigService, statSigClient)
        }
    }
}
