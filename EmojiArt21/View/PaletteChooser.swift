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
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                            .environmentObject(document)
                    } else {
                        PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                            .environmentObject(document)
                            .frame(width: 300, height: 500 )
                    }
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
    @Binding var isShowing: Bool
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button {
                        isShowing = false
                    } label: {
                        Text("Done")
                    }
                    .padding()

                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { (began) in
                        if !began {
                            document.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { (began) in
                        if !began {
                            chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    })
                }
                
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0)}, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: fontSize ))
                            .onTapGesture {
                                chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                            }
                    }
                    .frame(height: height)
                }
            }
             
        }
        .onAppear {
            paletteName = document.paletteNames[chosenPalette] ?? ""
        }
    }
    
    // MARK: - Drawing Constants
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    let fontSize: CGFloat = 40.0
}
