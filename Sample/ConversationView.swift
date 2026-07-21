//
//  ConversationView.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ConversationView: View {
    @Environment(\.state) private var state
    
    var editableState: Bindable<SimulatorState> {
        @Bindable var editableState = state
        return $editableState
    }
    
    var body: some View {
        if state.displayMessages.isEmpty {
            ContentUnavailableView {
                Label("No messages", systemImage: "bubble.left.and.exclamationmark.bubble.right")
            } description: {
                Text("Press Start Simulation to begin")
            } actions: {
                Button("Start", systemImage: "play", action: state.start)
                    .buttonStyle(.glassProminent)
            }
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: .md) {
                        ForEach(editableState.displayMessages) { message in
                            MessageRow(message: message)
                                .id(message.id)
                        }
                        
                        if state.isFinished {
                            SystemBanner(
                                content: "Session finished",
                                systemImage: "flag.pattern.checkered",
                                color: .gray
                            )
                        }
                        
                        TotalsSection()
                            .frame(maxWidth: .xxxl * .xs)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.lg)
                }
                .onChange(of: state.displayMessages.count) {
                    withAnimation(.interactiveSpring) {
                        proxy.scrollTo("scroll-bottom", anchor: .bottom)
                    }
                }
                .onChange(of: state.displayMessages.last?.content) {
                    proxy.scrollTo("scroll-bottom", anchor: .bottom)
                }
            }
        }
    }
}

#Preview("Empty") {
    ConversationView()
}

#Preview("With Messages") {
    ConversationView()
}
