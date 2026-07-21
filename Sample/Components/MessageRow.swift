//
//  MessageFlowSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct MessageRow: View {
    @Binding var message: DisplayMessage
    
    var body: some View {
        switch message.role {
            case .tool: ToolCallCard(message: $message)
            default: MessageBubble(message: message)
        }
    }
}

#Preview {
    let tool = ToolCall(
        toolName: "search",
        inputArgs: #"{"query": "Swift concurrency"}"#,
        result: "Found 42 results."
    )
    
    VStack(alignment: .leading, spacing: 12) {
        MessageRow(message: .constant(DisplayMessage(role: .system, content: "You are a helpful assistant.")))
        MessageRow(message: .constant(DisplayMessage(role: .user, content: "Tell me about Swift.")))
        MessageRow(message: .constant(DisplayMessage(role: .assistant, content: "Swift is a modern language by Apple.")))
        MessageRow(message: .constant(DisplayMessage(role: .tool, content: "", toolCall: tool)))
    }
    .padding()
    
}
