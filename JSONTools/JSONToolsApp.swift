//
//  JSONToolsApp.swift
//  JSONTools
//
//  Created by Fabricio Sffair on 17/05/26.
//

import SwiftUI
import Logging

@main
struct JSONToolsApp: App {
    init() {
        // Dev harness only: bootstrap swift-log so RailtracksInstrumentationKit's
        // trace/debug lines show in the Xcode console. The library itself never
        // bootstraps — that's the consuming app's job. Run JSONTools from Xcode
        // (⌘R) and watch the console to see the emission/parse logs.
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = .trace
            return handler
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
