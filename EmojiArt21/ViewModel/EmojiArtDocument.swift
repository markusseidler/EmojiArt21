//
//  EmojiArtDocument.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
 
    static let palette = "⭐️☁️🍎🌍🥨⚾️ "
    
//    @Published private var emojiArt: EmojiArt {
//        didSet {
////            print("json = \(String(decoding: emojiArt.json!, as: UTF8.self))")
//            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
//        }
//    }
    
    @Published private var emojiArt: EmojiArt
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    private var autoSaveCancellable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled )) ?? EmojiArt()
        autoSaveCancellable = $emojiArt.sink { (emojiArt) in
            print("json = \(String(decoding: emojiArt.json!, as: UTF8.self))")
            UserDefaults.standard.setValue(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
        fetchBackgroundImageData()
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    // MARK - Intents
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func removeEmoji(_ emoji: EmojiArt.Emoji) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis.remove(at: index)
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
            
        }
    }
    
//    private func fetchBackgroundImageData() {
//        backgroundImage = nil
//        if let url = emojiArt.backgroundURL {
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async {
//                        if url == self.emojiArt.backgroundURL {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
//
//        }
//    }
    
    private var myFetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            
            // making sure that outstanding requests are cancelled first
            myFetchImageCancellable?.cancel()
            
            // lecture 9: 53 minute
            myFetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                
                // transform this publisher that it publishes UIImage
                .map { data, response in UIImage(data: data) }
                
                // make sure that the publisher only publishes on main queue. URLSession works on the background queue
                .receive(on: DispatchQueue.main)
                
                // don't want to deal with errors. if error then publish nil
                .replaceError(with: nil)
                
                // assign it to key path var on object self, assign only works if failure is never or nil
                .assign(to: \.backgroundImage, on: self)
            
        }
    }
    
} 

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
