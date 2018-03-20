//
//  MapViewViewController.swift
//  Virtual-Tourist
//
//  Created by Sultan on 19/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewViewController: UIViewController,MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var Pin : AnnotationPin!
    var dataController : DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setMapRegion()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPressGesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    //Adding a Custom Annotation Pin to Map
    
     //func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       // let annotationView = MKAnnotationView(annotation: Pin, reuseIdentifier: "SavePin")
        //annotationView.image = UIImage(named: "placeholder")
        //let transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        //annotationView.transform = transform
        //return annotationView
    //}
    
    @objc func addAnnotation(press : UILongPressGestureRecognizer){
        if press.state == .began{
            let locationForAnnotation = press.location(in: mapView)
            let coordinatesForAnnotation = mapView.convert(locationForAnnotation, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinatesForAnnotation
            
            mapView.addAnnotation(annotation)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "photoCollectionVC") as! PhotoCollectionViewController
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "MapRegion", in: dataController.viewContext)
        let mapRegionToSave = MapRegion(entity: entity!, insertInto: dataController.viewContext)
        
        mapRegionToSave.centerlatitude = mapView.region.center.latitude
        mapRegionToSave.centerlongitude = mapView.region.center.longitude
        mapRegionToSave.spanlatitude = mapView.region.span.latitudeDelta
        mapRegionToSave.spanlongitude = mapView.region.span.longitudeDelta
        
        try? dataController.viewContext.save()
    }
    
    func setMapRegion(){
        var mapRegions = [MapRegion]()
        let fetchRequest:NSFetchRequest<MapRegion>=MapRegion.fetchRequest()
        do{
            mapRegions = try! dataController.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        let newMapRegion = mapRegions.last
        let coordinate = CLLocationCoordinate2D(latitude: (newMapRegion?.centerlatitude)!, longitude: (newMapRegion?.centerlongitude)!)
        let span = MKCoordinateSpanMake((newMapRegion?.spanlatitude)!, (newMapRegion?.spanlongitude)!)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    

}

