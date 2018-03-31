//
//  CollectionCell.swift
//  Virtual-Tourist
//
//  Created by Sultan on 21/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit

class CollectionCell:UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func initWithPhoto(recievedPhotoInstance : Photos){
        activityIndicator.startAnimating()
        if recievedPhotoInstance.imageData == nil {
            let imageURL = URL(string: recievedPhotoInstance.url!)
            URLSession.shared.dataTask(with: imageURL!){data,response,error in
                if error==nil{
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data! as Data)
                        self.activityIndicator.stopAnimating()
                    }
                }
                
                }.resume()
        } else {
            imageView.image = UIImage(data: recievedPhotoInstance.imageData!)
            activityIndicator.stopAnimating()
        }
    }
}
