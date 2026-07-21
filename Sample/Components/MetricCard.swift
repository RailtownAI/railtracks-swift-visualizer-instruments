//
//  MetricCard.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct MetricCard: View {
    let metric: MessageMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: .sm) {
            HStack(spacing: 6) {
                Circle()
                    .fill(roleColor)
                    .frame(width: 6, height: 6)
                Text(metric.role.displayLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(roleColor)
                Spacer()
                if metric.isActive {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(.circular)
                }
            }
            
            VStack(spacing: .xs) {
                TokenRow(label: "Input",  value: metric.inputTokens,  color: .blue)
                TokenRow(label: "Output", value: metric.outputTokens, color: .green)
            }
            
            HStack {
                Text("Cost")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(metric.cost, format: .currency(code: "USD").precision(.fractionLength(6)))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.primary)
            }
        }
        .padding(10)
        .clipShape(.rect(cornerRadius: .sm))
        .overlay {
            if metric.isActive {
                PulsingBorder(color: .red, cornerRadius: .sm)
            }
        }
    }
    
    private var roleColor: Color {
        switch metric.role {
            case .system:    .green
            case .user:      .red
            case .assistant: Color(red: 168/255, green: 85/255, blue: 247/255)
            case .tool:      .orange
        }
    }
}

#Preview {
    let active = MessageMetric(role: .assistant, inputTokens: 512, outputTokens: 256, isActive: true)
    let done   = MessageMetric(role: .user,      inputTokens: 128, outputTokens: 0,   isActive: false)
    
    return VStack(spacing: .sm) {
        MetricCard(metric: active)
        MetricCard(metric: done)
    }
    .padding()
}
