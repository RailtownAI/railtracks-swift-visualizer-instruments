//
//  TurnEditor.swift
//  Sample
//
//  Created by Cezar Mauricio on 07/05/26.
//

import SwiftUI

struct TurnEditor: View {
    
    @Binding var turn: ConversationTurn
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    TextEditor(text: $turn.content)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
                
                if turn.role == .assistant {
                    Section("Tool Call") {
                        ToolCallEditorRow(toolCall: $turn.toolCall)
                    }
                }
            }
            .navigationTitle(turn.role.displayLabel)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    @Previewable @State var turn: ConversationTurn = .init(role: .assistant, content: "")
    
    TurnEditor(turn: $turn)
}
