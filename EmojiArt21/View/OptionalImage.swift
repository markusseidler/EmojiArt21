//
//  OptionalImage.swift
//  EmojiArt21
//
//  Created by Markus Seidler on 12/3/21.
//

import SwiftUI

struct OptionalImage: View {
    var image: UIImage?
    
    var body: some View {
        Group {
            if image != nil {
                Image(uiImage: image!)
            }
        }
    }
}

struct OptionalImage_Previews: PreviewProvider {
    static var previews: some View {
        OptionalImage()
    }
}
