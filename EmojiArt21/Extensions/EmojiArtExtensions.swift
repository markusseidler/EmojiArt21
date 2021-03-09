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
}

extension URL {
    var imageURL: URL {
        // 53:00
        // why splitting it like that?
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

