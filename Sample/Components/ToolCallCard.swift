//
//  ToolCallCard.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ToolCallCard: View {
    
    @Environment(\.state) private var state
    
    @State var isExpanded: Bool = false
    @Binding var message: DisplayMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            VStack(alignment: message.role.alignment.horizontal, spacing: .sm) {
                HStack(spacing: .xs) {
                    RoleLabel(role: message.role)
                        .padding(.leading, .sm)
                    
                    if message.isStreaming {
                        Image(systemName: "progress.indicator")
                            .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let toolCall = message.toolCall {
                    Button(action: onTitleButtonTap) {
                        VStack(alignment: .leading, spacing: .sm) {
                            VStack(alignment: .leading) {
                                Text(toolCall.toolName)
                                    .font(.headline.monospaced())
                                Text("Tap to \(isExpanded ? "collapse" : "view tool call")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if isExpanded {
                                VStack(alignment: .leading, spacing: .xs) {
                                    Label("Input", systemImage: "arrow.down.square.fill")
                                        .imageScale(.small)
                                        .font(.subheadline)
                                        .labelIconToTitleSpacing(.xxs)
                                        .foregroundStyle(.tertiary)
                                    Text(toolCall.inputArgs)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(.pink)
                                        .textSelection(.enabled)
                                    
                                    Capsule()
                                        .fill(.clear)
                                        .frame(width: .xxl, height: .xxxs)
                                        .frame(height: .sm)
                                    
                                    Label("Output", systemImage: "arrow.up.square.fill")
                                        .font(.subheadline)
                                        .imageScale(.small)
                                        .labelIconToTitleSpacing(.xxs)
                                        .foregroundStyle(.tertiary)
                                    Text(toolCall.result)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(.cyan)
                                        .textSelection(.enabled)
                                }
                                .background {
                                    Capsule()
                                        .fill(.quaternary)
                                        .frame(height: .xxxs)
                                }
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .padding(.sm)
                    .glassEffect(.regular, in: .rect(cornerRadius: .sm))
                    .clipped()
                    .onAppear {
                        isExpanded = state.defaultShowToolCalls
                    }
                }
            }
            .padding(.sm)
            .glassEffect(
                .regular.tint(message.role.color.opacity(0.1)),
                in: .rect(cornerRadius: .md)
            )
            .overlay {
                PulsingBorder(playing: message.isStreaming, color: .orange, cornerRadius: .md)
            }
            .id(message.id)
            
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
    
    func onTitleButtonTap() {
        withAnimation(.easeOut) {
            isExpanded.toggle()
        }
    }
}

#Preview {
    @Previewable @State var message1 = DisplayMessage(
        role: .tool,
        content: "",
        toolCall: .init(
            toolName: "get_weather",
            inputArgs: #"{"location": "Paris, France"}"#,
            result: #"{"temperature": 18, "condition": "Sunny"}"#
        )
    )
    @Previewable @State var message2 = DisplayMessage(
        role: .tool,
        content: "",
        toolCall: .init(
            toolName: "get_weather",
            inputArgs: #"{"location": "Paris, France"}"#,
            result: #"{"temperature": 18, "condition": "Sunny"}"#
        ),
        isStreaming: true
    )
    
    @Previewable @State var message3 = DisplayMessage(role: .tool, content: "")
    @Previewable @State var message4 = DisplayMessage(role: .tool, content: "", isStreaming: true)
    
    ScrollView {
        VStack(spacing: 16) {
            ToolCallCard(message: $message1)
            
            ToolCallCard(message: $message2)
            
            ToolCallCard(message: $message3)
            
            ToolCallCard(message: $message4)
        }
        .padding()
    }
}
