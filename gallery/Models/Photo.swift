//
//  Photo.swift
//  gallery
//
//  Created by Admin on 13.04.17.
//  Copyright © 2017 justsayozz. All rights reserved.
//

import Foundation
import UIKit

class Photo {
    private static let urlKey = "url"
    private static let thumbnailUrlKey = "url_tn"
    private static let titleKey = "name"
    
    private var thumbImageDownloadTask: URLSessionDataTask?
    
    var imageUrl: String?
    var thumbnailImageUrl: String?
    var title: String?
    var thumbnailImage: UIImage?
    
    public init() {
    
    }
    
    public init(_ json: [String: Any]) {
        imageUrl = json[Photo.urlKey] as? String
        thumbnailImageUrl = json[Photo.thumbnailUrlKey] as? String
        title = json[Photo.titleKey] as? String
    }
    
    func getThumbImage(completion: @escaping (Bool) -> ()) {
        if thumbImageDownloadTask != nil && thumbImageDownloadTask?.state == .running {
            completion(false)
            return
        }
        
        guard thumbnailImage == nil else {
            completion(false)
            return
        }
        
        guard let thumbnailImageUrl = thumbnailImageUrl else {
            completion(false)
            return
        }
        
        if let imageUrl = URL(string: thumbnailImageUrl) {
            thumbImageDownloadTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                guard let data = data, error == nil else {
                    self.thumbnailImage = nil
                    completion(true)
                    return
                }
                
                self.thumbnailImage = UIImage(data: data)
                completion(true)
            }
            thumbImageDownloadTask?.resume()
        } else {
            completion(false)
        }
    }
    
    func getLargeImage(downloadComplete: @escaping (UIImage) -> (), downloadError: @escaping () -> ()) {
        guard let largeImageUrl = imageUrl else {
            downloadError()
            return
        }
        
        if let imageUrl = URL(string: largeImageUrl) {
            let imageDownloadTask = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                guard let data = data, error == nil else {
                    downloadError()
                    return
                }
                
                if let image = UIImage(data: data) {
                    downloadComplete(image)
                } else {
                    downloadError()
                }
            }
            imageDownloadTask.resume()
        } else {
            downloadError()
        }
    }
}
