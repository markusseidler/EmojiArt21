//
//  EmojiArt.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 6/3/21.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable {
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
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    // let caller handle error. Therefore, if someone asks to create with saved emoji and cannot, best to highlight it by returning nil -> fail-able init with init?
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            // can do this because its value type, get a copy of my self as newEmojiArt
            self = newEmojiArt
        }
    }
    
    // because of adding init -> losing now the  "free init" of init at variable level. Need to add it back with an empty init function
    init() {}
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiID))
    }
    
    
}
