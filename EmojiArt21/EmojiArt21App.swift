//
//  EmojiArt21App.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import SwiftUI

@main
struct EmojiArt21App: App {
    
//    let store = EmojiArtDocumentStore(named: "Emoji Art ")
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var store: EmojiArtDocumentStore {
        EmojiArtDocumentStore(directory: url)
    }
    
    var body: some Scene {
        WindowGroup {
//            EmojiArtDocumentView(document: EmojiArtDocument())
            EmojiArtDocumentChooser()
                .environmentObject(store)
                .onAppear {
//                    store.addDocument()
//                    store.addDocument(named: "Hello World")
                }
        }
    }
}


// credit portfolio

