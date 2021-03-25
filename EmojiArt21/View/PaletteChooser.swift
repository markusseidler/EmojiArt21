//
//  PaletteChooser.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 20/3/21.
//

import SwiftUI

struct PaletteChooser: View {
    
    @StateObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    chosenPalette = document.palette(after: chosenPalette)
                },
                onDecrement: {
                    chosenPalette = document.palette(before: chosenPalette )
                },
                label: {
                    EmptyView()
                })
            Text(document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "keyboard")
                .imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = true
                }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: $chosenPalette)
                        .environmentObject(document)
                        .frame(width: 300, height: 500 )
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: .constant(""))
    }
}


struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Palette Editor").font(.headline).padding()
            Divider()
//            Text(document.paletteNames[chosenPalette] ?? "")
//                .padding()
            TextField("Palette Name", text: $paletteName, onEditingChanged: { (began) in
                if !began {
                    document.renamePalette(chosenPalette, to: paletteName)
                }
            })
                .padding()
            TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { (began) in
                if !began {
                    chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                    emojisToAdd = ""
                }
            })
                .padding()
            Spacer()
            
        }
        .onAppear {
            paletteName = document.paletteNames[chosenPalette] ?? ""
        }
        
    }
}
