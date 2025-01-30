//
//  Untitled.swift
//  Simpless
//
//  Created by Ambarish Shivakumar on 04/12/24.
//

import SwiftUI

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct CachedImage: View {
    let url: URL
    
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
            image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadedImage = UIImage(data: data) {
                ImageCache.shared.setObject(downloadedImage, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    image = downloadedImage
                }
            }
        }.resume()
    }
}
