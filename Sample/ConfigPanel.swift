//
//  ConfigPanel.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct ConfigPanel: View {
    var body: some View {
        Form {
            ScenariosSection()
            TreeSection()
            ModeSection()
            SpeedSection()
            ToolCallSection()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    NavigationStack {
        
    }
    .inspector(isPresented: $isPresented) {
        ConfigPanel()
    }
}
