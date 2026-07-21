//
//  TreeSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 12/05/26.
//

import SwiftUI

struct TreeSection: View {
    @Environment(\.state) private var state

    var body: some View {
        Section("JSON Tree") {
            Button("Simulate JSON Tree", action: onSimulateTap)
            Button("Simulate Agent Graph", action: onAgentGraphTap)
        }
        .buttonSizing(.flexible)
    }

    func onSimulateTap() {
        state.emitJSONTree()
    }

    func onAgentGraphTap() {
        state.emitAgentCallGraph()
    }
}

#Preview {
    TreeSection()
        .padding()
}
