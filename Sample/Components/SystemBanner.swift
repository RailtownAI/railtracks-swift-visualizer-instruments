//
//  TokenLabel.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//


import SwiftUI

struct SystemBanner: View {
    
    let content: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        Label(content, systemImage: systemImage)
            .foregroundStyle(color)
            .padding(.sm)
            .padding(.trailing, .xxs)
            .glassEffect(.regular.tint(color.opacity(0.2)), in: .capsule)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    SystemBanner(
        content: "You are a helpful assistant. Answer concisely and clearly.",
        systemImage: "info.circle.fill",
        color: .green
    )
        .padding()
}
