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
                .foregroundColor(.white).overlay(
                    // need to wrap it in a Group as .overlay is not a ViewBuilder
                    Group {
                        if document.backgroundImage != nil {
                        Image(uiImage: document.backgroundImage!)
                        }
                    })
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    return drop(providers: providers) }
        }
    }
    
    private func drop(providers: [NSItemProvider]) -> Bool {
        let found = providers.loadFirstObject(ofType: URL.self) { url in
            document.setBackgroundURL(url)
            
            // lecture 7 1:19
        }
        
        return found
    }
    
    private let defaultFontSize: CGFloat = 40.0
}

