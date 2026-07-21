//
//  TokenRow.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct TokenRow: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
            TokenLabel(count: value, color: color)
        }
    }
}

#Preview {
    VStack(spacing: .sm) {
        TokenRow(label: "Input",  value: 1024, color: .blue)
        TokenRow(label: "Output", value: 512,  color: .green)
    }
    .padding()
}
