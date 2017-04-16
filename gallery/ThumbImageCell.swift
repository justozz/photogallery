//
//  ThumbImageCell.swift
//  gallery
//
//  Created by Admin on 13.04.17.
//  Copyright © 2017 justsayozz. All rights reserved.
//

import UIKit

class ThumbImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var photo: Photo?
    
    func setPhoto(photo: Photo?) {
        self.photo = photo
        guard let photo = photo else {
            return
        }
        
        titleLabel.text = photo.title
        imageView.image = nil
        if let image = photo.thumbnailImage {
            imageView.image = image
        } else {
            photo.getThumbImage(completion: { (refreshNeeded) in
                if refreshNeeded {
                    DispatchQueue.main.async {
                        self.imageView.image = photo.thumbnailImage
                    }
                }
            })
        }
    }
    
    func getPhoto() -> Photo? {
        return photo
    }
}
