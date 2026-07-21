//
//  PulsingBorder.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import SwiftUI

struct PulsingBorder: View {
    
    private let date: Date = .now
    
    var playing: Bool = false
    let color: Color
    let cornerRadius: CGFloat
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.25, paused: !playing)) { context in
            let distance = context.date.timeIntervalSince(date)
            let progress = playing ? abs(sin(distance * .pi)) + 0.1 : .zero
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: 1)
                .animation(.none, value: progress)
                .opacity(progress)
                .animation(.linear(duration: 0.5), value: progress)
                .shadow(color: color, radius: 5)
                .clipShape(.rect(cornerRadius: cornerRadius).inset(by: -1))
        }
    }
}

#Preview {
    @Previewable @State var isPlaying = true
    @Previewable @State var size = CGSize(width: 200, height: 80)
    
    Button(isPlaying ? "Pause" : "Play") {
        isPlaying.toggle()
    }
    
    Button("Change size") {
        size = .init(width: .random(in: 100...300), height: .random(in: 50...150))
    }
    
    RoundedRectangle(cornerRadius: .sm)
        .fill(.clear)
        .frame(width: size.width, height: size.height)
        .overlay { PulsingBorder(playing: isPlaying, color: .orange, cornerRadius: .sm) }
        .padding()
}
