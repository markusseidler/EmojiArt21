//
//  ContentView.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @StateObject var document: EmojiArtDocument
    
    @State private var selectedEmojis: Set<EmojiArt.Emoji> = []
    
   
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * (selectedEmojis.isEmpty ? gestureZoomScale : 1)
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
   
    @GestureState private var gesturePanOffsetEmoji: CGSize = .zero
    
    private var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @State private var chosenPalette: String = ""
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                    .onAppear {
                        chosenPalette = document.defaultPalette
                    }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
    
                
                Spacer()
                Button(action: {
                    selectedEmojis.forEach { (emoji) in
                        document.removeEmoji(emoji)
                        selectedEmojis.remove(emoji)
                    }
                }, label: {
                    Image(systemName: "trash.fill")
                        .font(animatableWithSize: defaultEmojiSize)
//
                })
                .disabled(selectedEmojis.isEmpty)
                .padding()
            }
            
            
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundColor(.white).overlay(
                            // need to wrap it in a Group as .overlay is not a ViewBuilder
                            OptionalImage(image: document.backgroundImage)
                                .scaleEffect(zoomScale)
                                .offset(panOffset))
                        .gesture(doubleTapToZoom(in: geometry.size))
                        .gesture(singleTapToDeselectOrDoubleTapToZoom(in: geometry.size))
                    
                    
                    if isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(document.emojis) { emoji in
                                Text(emoji.text)
                                    .font(animatableWithSize: emoji.fontSize * zoomScale(for: emoji))
                                    .padding()
                                    .background(Circle()
                                                    .stroke(isInSelectedEmojis(emoji) ? Color.black : Color.clear))
                                    .position(position(for: emoji, in: geometry.size))
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            selectedEmojis.toggleMatching(emoji)
                                            
                                        }
                                }
                                    .gesture(panGestureEmoji())
                                    .gesture(longPressToRemove(emoji: emoji))
                        }
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea(.all)
//                .onReceive(document.$backgroundImage) { image
//                    zoomToFit(image, in: geometry.size)
//                }
//                .onReceive(document.$backgroundImage, perform: { image in
//                    zoomToFit(image, in: geometry.size)
//                })
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)

                    return drop(providers: providers, at: location)
                }
                .navigationBarItems(leading: pickImage, trailing: Button(action: {
                    if let url = UIPasteboard.general.url,  url != document.backgroundURL {
//                        document.backgroundURL = url
                        confirmBackgroundPaste = true
                    } else {
                        explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard")
                        .imageScale(.large)
                        .alert(isPresented: $explainBackgroundPaste) {
                            Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document"),
                                dismissButton: .default(Text("Ok")))
                        }
                }))

            }
            .zIndex(-1)
        }
        .alert(isPresented: $confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                primaryButton: .default(Text("Ok"), action: {
                    document.backgroundURL = UIPasteboard.general.url
                }),
                secondaryButton: .cancel())
        }
    }
    
//    private func font(for emoji: EmojiArt.Emoji) -> Font {
//        Font.system(size: emoji.fontSize * zoomScale)
//    }
    
    @State private var showImagePicker = false
    
    private var pickImage: some View {
        Image(systemName: "photo")
            .imageScale(.large)
            .foregroundColor(.accentColor)
            .onTapGesture {
                showImagePicker = true
            }
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker() { image in
                    if image != nil {
                        DispatchQueue.main.async {
                            document.backgroundURL  = image!.storeInTheFileSystem()
                        }
                    }
                    showImagePicker = false
                }
            })
    }
    
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2 )
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height )
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.backgroundURL = url
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation {
                     zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func singleTapToDeselectOrDoubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 1)
//            .exclusively(before: doubleTabToZoom(in: size))
            .onEnded { _ in
                withAnimation(.easeInOut(duration: 0.4)) {
                    selectedEmojis.removeAll()
                }
               
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale, body: { (latestGestureScale, ourGestureStateInOut, transaction) in
                // other than an initial value you should never assign a value to gestureZoomScale. Let the gesture handle it to assign values. Lecture 8 1:05
                ourGestureStateInOut = latestGestureScale
            })
            .onEnded { (finalGestureScale) in
                if selectedEmojis.isEmpty {
                    document.steadyStateZoomScale *= finalGestureScale
                } else {
                    selectedEmojis.forEach { (emoji) in
                        document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                }
//
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { (latestGestureScale, ourGestureStateInOut, transaction) in
                ourGestureStateInOut = latestGestureScale.translation / zoomScale
            })
            .onEnded { (finalDragGestureValue) in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private func panGestureEmoji() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffsetEmoji) { (latestDragGestureValue, ourGestureStateInOut, transaction) in
                ourGestureStateInOut = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { (finalDragGestureValue) in
                let distanceDragged = finalDragGestureValue.translation / zoomScale
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    for emoji in selectedEmojis {
                        document.moveEmoji(emoji, by: distanceDragged)
                    }
                }
            }
    }
    
    private func longPressToRemove(emoji: EmojiArt.Emoji) -> some Gesture {
        LongPressGesture(minimumDuration: 1)
            .onEnded { (_) in
                document.removeEmoji(emoji)
            }
    }
    
    private func zoomScale(for emoji: EmojiArt.Emoji) -> CGFloat {
        if isInSelectedEmojis(emoji) {
            return document.steadyStateZoomScale * gestureZoomScale
        } else {
            return zoomScale
        }
    }
    
    private func isInSelectedEmojis(_ emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.contains(matching: emoji)
    }
    
    private let defaultEmojiSize: CGFloat = 40.0
}



