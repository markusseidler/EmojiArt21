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
                .onDrop(of: ["public.image"], isTargeted: nil) { providers, location in
                    return drop(providers: providers) }
            
            // add image as overlay ... 1:00:00 lecture 6
        }
    }
    
    private func drop(providers: [NSItemProvider]) -> Bool {
        let found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)") 
            document.setBackgroundURL(url)
        }
        
        return found
    }
    
    private let defaultFontSize: CGFloat = 40.0
}

