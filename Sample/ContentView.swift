//
//  ContentView.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.state) private var state
    @State private var showConfig = true
    
    var body: some View {
        NavigationSplitView(
            columnVisibility: .constant(.doubleColumn)
        ) {
            EmptyView()
                .toolbar(removing: .sidebarToggle)
        } content: {
            MessageFlowSection()
        } detail: {
            ConversationView()
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        if state.isRunning {
                            Button("Stop", systemImage: "stop.fill", action: state.stop)
                        } else if state.isFinished {
                            Button("Restart", systemImage: "arrow.counterclockwise", action: state.restart)
                        } else {
                            Button("Start", systemImage: "play.fill", action: state.start)
                                .buttonStyle(.glassProminent)
                        }
                    }
                    ToolbarSpacer()
                    ToolbarItem(placement: .primaryAction) {
                        Button("Metrics", systemImage: "sidebar.right") {
                            showConfig.toggle()
                        }
                    }
                }
        }
        .navigationSplitViewStyle(.balanced)
        .inspector(isPresented: $showConfig) {
            ConfigPanel()
        }
    }
}

#Preview {
    ContentView()
}
