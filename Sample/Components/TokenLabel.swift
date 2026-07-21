//
//  TokenLabel.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct TokenLabel: View {
    
    let count: Int
    let color: Color
    
    var body: some View {
        Text("\(count) tok")
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(color)
    }
}

#Preview {
    TokenLabel(count: 200, color: .red)
}
