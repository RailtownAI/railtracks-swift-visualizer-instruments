//
//  ScenariosSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ScenariosSection: View {
    @Environment(\.state) private var state
    
    var body: some View {
        Section("Scenarios") {
            Button("Simple Q&A", action: onSimpleQAButtonTap)
            HStack {
                Button("Simple Carrer Advice", action: onSimpleCarrerAdviceButtonTap)
                Button("Simple Philosophy", action: onSimplePhilosophyButtonTap)
            }
            
            Button("Tool Use", action: onToolUseButtonTap)
            HStack {
                Button("Tool How works", action: onToolUseHowWorksButtonTap)
                Button("Tool Travel planning", action: onToolUseTravelPlanningButtonTap)
            }
        }
        .buttonSizing(.flexible)
    }
    
    func onSimpleQAButtonTap() {
        state.loadScenario(.simpleQA)
    }
    
    func onSimpleCarrerAdviceButtonTap() {
        state.loadScenario(.simpleCarrerAdvice)
    }
    
    func onSimplePhilosophyButtonTap() {
        state.loadScenario(.simplePhilosophy)
    }
    
    func onToolUseButtonTap() {
        state.loadScenario(.toolUse)
    }
    
    func onToolUseHowWorksButtonTap() {
        state.loadScenario(.toolUseHowWorks)
    }
    
    func onToolUseTravelPlanningButtonTap() {
        state.loadScenario(.toolUseTravelPlanning)
    }
}

#Preview {
    ScenariosSection()
        .padding()
}
