//
//  SpeedSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct SpeedSection: View {
    @Environment(\.state) private var state
    
    var editableState: Bindable<SimulatorState> {
        @Bindable var editableState = state
        return $editableState
    }
    
    var token: Int {
        Int(state.tokenDelayMs)
    }
    
    var async: Int {
        Int(state.asyncDelayMs)
    }
    
    var body: some View {
        Section {
            Picker("Speed", selection: editableState.speedPreset) {
                ForEach(SpeedPreset.allCases) { preset in
                    Text(preset.label).tag(preset)
                }
            }
            .pickerStyle(.palette)
            .buttonSizing(.flexible)
            
            if state.speedPreset == .custom {
                Slider(value: editableState.customDelayMs, in: 10...2000)
            }
        } header: {
            Text("Speed")
        } footer: {
            Text("\(token) ms/token · \(async) ms/message")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .labelsHidden()
    }
}

#Preview {
    SpeedSection()
        .padding()
}
