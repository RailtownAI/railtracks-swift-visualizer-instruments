//
//  ToolCallSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ToolCallSection: View {
    @Environment(\.state) private var state
    
    var editableState: Bindable<SimulatorState> {
        @Bindable var editableState = state
        return $editableState
    }
    
    var body: some View {
        Section {
            Toggle("Enable tool calls", isOn: editableState.toolCallEnabled)
            Toggle("Expand tool blocks", isOn: editableState.defaultShowToolCalls)
        } header: {
            Text("Tool calling")
        } footer: {
            Text("Shows tool_use blocks during playback")
        }
    }
}

#Preview {
    ToolCallSection()
        .padding()
}
