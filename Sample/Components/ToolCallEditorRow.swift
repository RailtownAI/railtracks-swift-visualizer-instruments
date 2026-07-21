import SwiftUI

struct ToolCallEditorRow: View {
    @Binding var toolCall: ToolCall?
    
    var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if toolCall == nil {
                        toolCall = ToolCall()
                    } else {
                        toolCall = nil
                    }
                }
            } label: {
                HStack(spacing: .xs) {
                    Image(systemName: toolCall != nil ? "checkmark.square.fill" : "square")
                        .font(.caption)
                    Text("Has tool call")
                        .font(.caption)
                }
                .foregroundStyle(toolCall != nil ? Color.orange : .secondary)
            }
            .buttonStyle(.plain)
            
            if toolCall != nil {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Tool name", text: Binding(
                        get: { toolCall?.toolName ?? "" },
                        set: { toolCall?.toolName = $0 }
                    ))
                    .font(.system(.caption, design: .monospaced))
                    .textFieldStyle(.plain)
                    .padding(5)
                    .clipShape(.rect(cornerRadius: 4))
                    
                    TextEditor(text: Binding(
                        get: { toolCall?.inputArgs ?? "" },
                        set: { toolCall?.inputArgs = $0 }
                    ))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(minHeight: .xxl, maxHeight: 80)
                    .scrollContentBackground(.hidden)
                    .padding(5)
                    .clipShape(.rect(cornerRadius: 4))
                    
                    TextEditor(text: Binding(
                        get: { toolCall?.result ?? "" },
                        set: { toolCall?.result = $0 }
                    ))
                    .font(.system(size: 10, design: .monospaced))
                    .frame(minHeight: .xxl, maxHeight: 80)
                    .scrollContentBackground(.hidden)
                    .padding(5)
                    .clipShape(.rect(cornerRadius: 4))
                }
                .padding(.leading, .sm)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.orange.opacity(0.4))
                        .frame(width: .xxs)
                        .clipShape(.rect(cornerRadius: 1))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var toolCall: ToolCall? = nil
    ToolCallEditorRow(toolCall: $toolCall)
        .padding()
}
