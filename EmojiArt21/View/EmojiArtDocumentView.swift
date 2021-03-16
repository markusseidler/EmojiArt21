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
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
      steadyStatePanOffset + gesturePanOffset * zoomScale
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag { NSItemProvider(object: emoji as NSString) }
                            
                    }
                }
            }
            .padding(.horizontal)
            
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
                    ForEach(document.emojis) { emoji in
                        ZStack {
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .padding()
                                .background(Circle()
                                                .stroke(isInSelectedEmojis(emoji) ? Color.black : Color.clear))
                                .position(position(for: emoji, in: geometry.size))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        selectedEmojis.toggleMatching(emoji)
                                    }
                                   
                            }
                        }
                    }
                }
                .gesture(zoomGesture())
                .gesture(panGesture())
                .clipped()
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    
                    return drop(providers: providers, at: location)
                }
                
            }
        }
    }
    
//    private func font(for emoji: EmojiArt.Emoji) -> Font {
//        Font.system(size: emoji.fontSize * zoomScale)
//    }
    
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2 )
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height )
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.setBackgroundURL(url)
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        
        return found
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
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
                steadyStateZoomScale *= finalGestureScale
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset, body: { (latestGestureScale, ourGestureStateInOut, transaction) in
                ourGestureStateInOut = latestGestureScale.translation / zoomScale
            })
            .onEnded { (finalDragGestureValue) in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private func isInSelectedEmojis(_ emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.contains(matching: emoji)
    }
    
    private let defaultEmojiSize: CGFloat = 40.0
}



