//
//  CommonUtility.swift
//  Streameo
//
//  Created by Suraj Kumar on 04/07/24.
//

import Foundation
import UIKit

class CommonUtilityFunctions {
    
    static let shared = CommonUtilityFunctions()
    
    public func downloadImage(from url: URL, for imageView: UIImageView) {
        let url = URL(string: url.absoluteString.replacingOccurrences(of: "http", with: "https"))!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No image data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        }.resume()
    }

}
