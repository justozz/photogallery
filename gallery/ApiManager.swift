//
//  ApiManager.swift
//  gallery
//
//  Created by Admin on 13.04.17.
//  Copyright © 2017 justsayozz. All rights reserved.
//

import Foundation

class ApiManager {
    static let sharedInstance = ApiManager()
    static let getPhotosUrl = "http://www.xiag.ch/share/testtask/list.json"
    
    private init() {
        
    }
    
    func getPhotos(completion: @escaping ([Photo]?) -> (), error: @escaping () -> ()) {
        if let url = URL(string: ApiManager.getPhotosUrl) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard err == nil else {
                    error()
                    return
                }
                
                guard let data = data else {
                    error()
                    return
                }
                
                do {
                    let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let jsonArray = jsonArray as? [Any] {
                        var photos = [Photo]()
                        for item in jsonArray {
                            if let json = item as? [String: Any] {
                                photos.append(Photo(json))
                            }
                        }
                        completion(photos)
                        return
                    }
                } catch {
                    
                }
                error()
            }
            task.resume()
        } else {
            error()
        }
    }
}
