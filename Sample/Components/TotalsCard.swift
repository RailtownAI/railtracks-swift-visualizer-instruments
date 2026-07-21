//
//  TotalsSection.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct TotalsSection: View {
    
    @Environment(\.state) private var state
    
    var body: some View {
        VStack {
            TokenRow(label: "Input",  value: state.totalInputTokens,  color: .blue)
            TokenRow(label: "Output", value: state.totalOutputTokens, color: .green)
            Divider()
            HStack {
                Text("Total Cost")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(state.totalCost, format: .currency(code: "USD").precision(.fractionLength(6)))
                    .font(.system(.caption2, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.sm)
        .glassEffect(.regular,in: .rect(cornerRadius: .sm + .xs))
        .padding(.sm)
    }
}

#Preview {
    TotalsSection()
        .padding()
}
