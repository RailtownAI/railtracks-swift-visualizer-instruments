//
//  RoleLabel.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct RoleLabel: View {
    
    let role: MessageRole
    var context: String? = nil
    
    var body: some View {
        HStack(spacing: .xs) {
            Label(role.displayLabel, systemImage: role.displayImage)
            if let context {
                Text("• \(context)")
            }
        }
        .imageScale(.small)
        .labelIconToTitleSpacing(.xs)
        .font(.subheadline)
        .foregroundStyle(role.color)
    }
}

#Preview {
    RoleLabel(role: .assistant)
}
