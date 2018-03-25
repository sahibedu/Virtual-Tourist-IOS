//
//  PhotoCollectionViewController.swift
//  Virtual-Tourist
//
//  Created by Sultan on 20/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadDataBtn: UIButton!
    
    var dataController : DataController!
    var pinRecieved : MKAnnotation!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        NetworkingFlickr(pin: pinRecieved,dataaController : dataController)
    }
    
    func setupInitialView(){
        mapView.addAnnotation(pinRecieved)
        mapView.setRegion(MKCoordinateRegionMake(pinRecieved.coordinate, MKCoordinateSpanMake(0.05, 0.05)), animated: true)
    }
    
    
    
    
}
