//
//  MessageBubble.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct MessageBubble: View {
    
    @Environment(\.state) private var state
    
    let message: DisplayMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            
            VStack(alignment: message.role.alignment.horizontal, spacing: .sm) {
                HStack(spacing: .xs) {
                    RoleLabel(role: message.role)
                    
                    if message.isStreaming {
                        Image(systemName: "progress.indicator")
                            .symbolEffect(
                                .variableColor.iterative.dimInactiveLayers.nonReversing,
                                options: .repeat(.continuous)
                            )
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !message.content.isEmpty {
                    Text(message.attributedContent)
                }
                
                if let toolCall = message.toolCall {
                    Text(toolCall.result)
                }
            }
            .padding(.horizontal, .md)
            .padding(.vertical, .sm)
            .glassEffect(
                .regular.tint(message.role.color.opacity(0.1)),
                in: .rect(cornerRadius: .md)
            )
            .overlay {
                PulsingBorder(playing: message.isStreaming, color: message.role.color, cornerRadius: .md)
            }
            
            if let metrics = state.metrics.first(where: { $0.id == message.id }) {
                Label {
                    Text(
                    """
                    \(Text(metrics.inputTokens, format: .number).foregroundStyle(.blue))\
                    /\
                    \(Text(metrics.outputTokens, format: .number).foregroundStyle(.green))
                    """
                    )
                } icon: {
                    Image(systemName: "arrow.right.filled.filter.arrow.right")
                        .foregroundStyle(.secondary)
                }
                .font(.caption.monospaced())
                .labelIconToTitleSpacing(.xxs)
                .imageScale(.small)
                .foregroundStyle(.tertiary)
                .padding(.vertical, .xxs)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role.alignment)
    }
}

#Preview {
    VStack {
        MessageBubble(
            message: .init(id: .init(), role: .assistant, content: "The capital of France is Paris.")
        )
        
        MessageBubble(
            message: .init(id: .init(), role: .assistant, content: "The capital of France is Paris.", isStreaming: true)
        )
    }
    .padding()
}
