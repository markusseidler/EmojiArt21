//
//  EmojiArt.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import Foundation

struct EmojiArt {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable {
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x // offset from the center
            self.y = y // offset from the center
            self.size = size
            self.id = id 
        }
        
        let text: String
        var x: Int
        var y: Int
        var size: Int
        var id: Int

    }
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiID))
    }
    
    
}
