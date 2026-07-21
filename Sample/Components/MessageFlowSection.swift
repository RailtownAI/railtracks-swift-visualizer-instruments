//
//  MessageFlowSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct MessageFlowSection: View {
    
    @Environment(\.state) private var state
    
    @State private var editingTarget: Binding<ConversationTurn>?
    
    var showDeleteButton: Bool {
        state.configTurns.count > 1
    }
    
    var body: some View {
        List {
            LabeledContent {
                TokenLabel(count: estimateTokens(state.systemPrompt), color: MessageRole.system.color)
            } label: {
                RoleLabel(role: .system)
                Text(state.systemPrompt)
            }
            
            ForEach(Bindable(state).configTurns) { $turn in
                Button {
                    editingTarget = $turn
                } label: {
                    LabeledContent {
                        TokenLabel(count: estimateTokens(turn.content), color: turn.role.color)
                    } label: {
                        RoleLabel(role: turn.role)
                        Text(turn.content)
                        if turn.toolCall != nil {
                            Label("Tool Call", systemImage: "wrench.and.screwdriver.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, .xs)
                        }
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .swipeActions {
                    if showDeleteButton {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            onDeleteButtonTap(for: turn)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .toolbar {
            Button("Add", systemImage: "plus", action: onAddButtonTap)
        }
        .sheet(item: $editingTarget, content: TurnEditor.init)
    }
    
    func onAddButtonTap() {
        let last = state.configTurns.last?.role ?? .assistant
        let next: MessageRole = last == .user ? .assistant : .user
        state.configTurns.append(ConversationTurn(role: next, content: ""))
    }
    
    func onDeleteButtonTap(for turn: ConversationTurn) {
        state.configTurns.removeAll { $0.id == turn.id }
    }
}

#Preview {
    MessageFlowSection()
        .padding()
}
