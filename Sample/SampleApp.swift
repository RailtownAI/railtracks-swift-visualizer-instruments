//
//  SampleApp.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

@main
struct SampleApp: App {
    @State private var state = SimulatorState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.state, state)
        }
        .defaultSize(width: 1280, height: 780)
        .windowResizability(.contentMinSize)
        .commands {
            InspectorCommands()
        }
    }
}
