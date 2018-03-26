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
    
    func initWithPhoto(photoURL : String){
        activityIndicator.startAnimating()
        let imageURL = URL(string: photoURL)
            URLSession.shared.dataTask(with: imageURL!){data,response,error in
                if error==nil{
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data! as Data)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        }
                }
                
            }.resume()
        }
}
