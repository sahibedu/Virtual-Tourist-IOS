//
//  AnnotationPin.swift
//  Virtual-Tourist
//
//  Created by Sultan on 20/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import MapKit

class AnnotationPin : NSObject,MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title : String,coordinate : CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
