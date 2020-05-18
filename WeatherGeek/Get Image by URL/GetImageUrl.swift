//
//  GetImageUrl.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/19/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation
import UIKit

class GetImageUrl {
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    public final func load(url: NSURL, completion: @escaping (UIImage?) -> Swift.Void) {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            completion(cachedImage)
            return
        }
        // In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        // Go fetch the image.
        ImageURLProtocol.urlSession().dataTask(with: url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image.
            guard let responseData = data, let image = UIImage(data: responseData),
                let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            // Cache the image.
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            // Iterate over each requestor for the image and pass it back.
            for block in blocks {
                DispatchQueue.main.async {
                    block(image)
                }
            }
        }.resume()
    }

}
