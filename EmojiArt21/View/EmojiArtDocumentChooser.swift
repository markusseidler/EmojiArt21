//
//  EmojiArtDocumentChooser.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 27/3/21.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                                    .navigationBarTitle(store.name(for: document))) {
                        Text(store.name(for: document))
                    }
                }
            }
            .navigationTitle(store.name)
            .navigationBarItems(leading: Button(action: {
                store.addDocument()
            }, label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }))
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
