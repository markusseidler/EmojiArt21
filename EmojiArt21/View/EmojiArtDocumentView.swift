//
//  ContentView.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @StateObject var document: EmojiArtDocument
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultFontSize))
                    }
                }
            }
            .padding(.horizontal)
            
            Rectangle()
                .foregroundColor(.yellow)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
    }
    
    private let defaultFontSize: CGFloat = 40.0
}

