//
//  ModeSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ModeSection: View {
    @Environment(\.state) private var state
    
    var editableState: Bindable<SimulatorState> {
        @Bindable var editableState = state
        return $editableState
    }
    
    var modeDescription: String {
        switch state.simulationMode {
            case .stream:  "Tokens appear one by one as they're generated."
            case .instant: "Full message appears after a delay."
        }
    }
    
    var body: some View {
        Section {
            Picker("Simulation Mode", selection: editableState.simulationMode) {
                ForEach(SimulationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Simulation Mode")
        } footer: {
            Text(modeDescription)
        }
    }
}

#Preview {
    ModeSection()
        .padding()
}
