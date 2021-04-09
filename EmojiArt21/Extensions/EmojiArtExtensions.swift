//
//  EmojiArtExtensions.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 8/3/21.
//

import SwiftUI

extension Collection where Element: Identifiable {
    func firstIndex(matching element: Element) -> Index? {
        firstIndex(where: { $0.id == element.id } )
    }
    
    func contains(matching element: Element) -> Bool {
        self.contains(where: { $0.id == element.id })
    }
}

extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponent = query.components(separatedBy: "=")
            if queryComponent.count == 2 {
                if queryComponent[0] == "imgurl", let url = URL(string: queryComponent[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        
        return self.baseURL ?? self
    }
    
    
}
// function above checks to see if there is an embedded imgurl reference
//example of imgurl
//https://www.google.com/imgres?imgurl=https%3A%2F%2Fi.pinimg.com%2Foriginals%2Ff0%2F2f%2Fb4%2Ff02fb4602fcc92c4b9c810aba0f57b55.jpg&imgrefurl=https%3A%2F%2Fwww.pinterest.com%2Fpin%2F502292164689416336%2F&tbnid=YqeQ7UgF149swM&vet=12ahUKEwinpcOmuqLvAhXD03MBHXC4BasQMygHegUIARCTAg..i&docid=d-svTenQmyUrUM&w=450&h=341&itg=1&q=countryside%20cartoon&client=safari&ved=2ahUKEwinpcOmuqLvAhXD03MBHXC4BasQMygHegUIARCTAg

extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = self.first(where: { $0.canLoadObject(ofClass: theType)}) {
            provider.loadObject(ofClass: theType) { (object, error) in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
            if let provider = self.first(where: { $0.canLoadObject(ofClass: theType) }) {
                let _ = provider.loadObject(ofClass: theType) { object, error in
                    if let value = object {
                        DispatchQueue.main.async {
                            load(value)
                        }
                    }
                }
                return true
            }
            return false
        }
    
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        self.loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
           self.loadObjects(ofType: theType, firstOnly: true, using: load)
       }
    
}

extension GeometryProxy {
    func convert(_ point: CGPoint, from coordinateSpace: CoordinateSpace) -> CGPoint {
        let frame = self.frame(in: coordinateSpace)
        return CGPoint(x: point.x - frame.origin.x, y: point.y - frame.origin.y)
        
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func * (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    static func * (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func / (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
    static func / (lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

extension Set where Element: Identifiable {
    mutating func toggleMatching(_ element: Element) {
        if contains(matching: element) {
            self.remove(element)
        } else {
            self.insert(element)
        }
    }
}

extension String {
    
    // returns self without duplicate Charaters
    // not very efficient, so only use for small strings
    
    func uniqued() -> String {
        var uniqued = ""
        for ch in self {
            if !uniqued.contains(ch) {
                uniqued.append(ch)
            }
        }
        
        return uniqued
    }
    
    // returns self but with numbers appended to the end
    func uniqued<StringCollection>(withRespectTo otherStrings: StringCollection) -> String where StringCollection: Collection, StringCollection.Element == String {
        var unique = self
        while otherStrings.contains(unique) {
            unique = unique.incremented
        }
        
        return unique
    }
    
    
    // if a number is at the end of this String, this increments that number. Otherwise, it appends the number 1
    
    var incremented: String {
        let prefix = String(self.reversed().drop(while: {
            $0.isNumber
        }).reversed())
        
        if let number = Int(self.dropFirst(prefix.count)) {
            return "\(prefix) \(number+1)"
        } else {
            return "\(self) 1"
        }
    }
}

extension UIImage {
    func storeInTheFileSystem(name: String = "\(Date().timeIntervalSince1970)") -> URL? {
        var url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        url = url?.appendingPathComponent(name)
         
        if url != nil {
            do {
                try jpegData(compressionQuality: 1.0)?.write(to: url! )
            } catch {
                url = nil
            }
        }
        
        return url
    }
    
}
