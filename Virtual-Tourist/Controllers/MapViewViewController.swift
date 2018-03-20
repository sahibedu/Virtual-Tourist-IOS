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

class MapViewViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var isEditingStateOn : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setMapRegion()
        longPressGesture()
        setUpFetchedResults()
        FetchPinFromCD()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setUpFetchedResults() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func FetchPinFromCD(){
        for objects in fetchedResultsController.fetchedObjects!{
            let annotationCoordinate = CLLocationCoordinate2D(latitude: objects.latitude, longitude: objects.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = annotationCoordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func SavePinToCD(Coordinates : CLLocationCoordinate2D){
        let pinToAdd = Pin(context: dataController.viewContext)
        pinToAdd.latitude = Coordinates.latitude
        pinToAdd.longitude = Coordinates.longitude
        try? dataController.viewContext.save()
    }
    
    func longPressGesture(){
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
            SavePinToCD(Coordinates: coordinatesForAnnotation)
        }
    }
    
    
    fileprivate func DeletePinFromCD(_ viewToDelete: MKAnnotation?, _ mapView: MKMapView) {
        for pins in fetchedResultsController.fetchedObjects!{
            if (pins.latitude == viewToDelete?.coordinate.latitude && pins.longitude == viewToDelete?.coordinate.longitude){
                dataController.viewContext.delete(pins)
                mapView.removeAnnotation(viewToDelete!)
                break
            }
        }
        try? dataController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditingStateOn{
            DeletePinFromCD(view.annotation, mapView)
        } else {
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "photoCollectionVC") as! PhotoCollectionViewController
            destinationVC.dataController = dataController
            destinationVC.pinRecieved = view.annotation
            navigationController?.pushViewController(destinationVC, animated: true)
        }
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
        }
        if mapRegions.count > 0 {
            let newMapRegion = mapRegions.last
            let coordinate = CLLocationCoordinate2D(latitude: (newMapRegion?.centerlatitude)!, longitude: (newMapRegion?.centerlongitude)!)
            let span = MKCoordinateSpanMake((newMapRegion?.spanlatitude)!, (newMapRegion?.spanlongitude)!)
            let region = MKCoordinateRegionMake(coordinate, span)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    @IBAction func EditButtonSet(_ sender: Any) {
        isEditingStateOn = !isEditingStateOn
        if isEditingStateOn{
            self.navigationItem.title = "Editing Mode on"
        } else {
            self.navigationItem.title = "Map View"
        }
    }
    
}

