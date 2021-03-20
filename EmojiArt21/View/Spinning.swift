//
//  Spinning.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 20/3/21.
//

import SwiftUI

struct Spinning: ViewModifier {
    
    @State private var isVisible: Bool = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false))
            .onAppear {
                isVisible = true
            }
    }
    
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}
