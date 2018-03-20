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
    var dataController : DataController!
    var pinRecieved : MKAnnotation!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
    }
    
    func setupInitialView(){
        let coordinate = CLLocationCoordinate2D(latitude: pinRecieved.coordinate.latitude, longitude: pinRecieved.coordinate.longitude)
        let span = MKCoordinateSpanMake(pinRecieved.coordinate.latitude, pinRecieved.coordinate.longitude)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
}
