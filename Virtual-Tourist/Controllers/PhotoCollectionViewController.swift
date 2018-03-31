//
//  PhotoCollectionViewController.swift
//  Virtual-Tourist
//
//  Created by Sultan on 20/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadDataBtn: UIButton!
    
    var dataController : DataController!
    var pinRecieved : MKAnnotation!
    var fetchedResultsController:NSFetchedResultsController<Photos>!
    var pinSaved : Pin!
    var editMode: Bool = false

 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResults()
        try? fetchedResultsController.performFetch()
            if (pinSaved.photos?.count)! < 1{
                _ = NetworkingFlickr(coords: pinRecieved, dataaController: dataController, pinToSave: pinSaved)
        } 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Perfromed Fetch on PhotoCollectionVC")
        try? fetchedResultsController.performFetch()
    }
    
    func setupInitialView(){
        mapView.addAnnotation(pinRecieved)
        mapView.setRegion(MKCoordinateRegionMake(pinRecieved.coordinate, MKCoordinateSpanMake(0.05, 0.05)), animated: true)
    }
    
    fileprivate func setUpFetchedResults() {
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", argumentArray: [pinSaved])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count != nil ? (fetchedResultsController.fetchedObjects?.count)! : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let prototypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionCell
        prototypeCell.initWithPhoto(recievedPhotoInstance: (fetchedResultsController.fetchedObjects![indexPath.row]))
        return prototypeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (navigationItem.rightBarButtonItem?.title == "Done"){
            let object = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(object)
            try? dataController.viewContext.save()
            collectionView.reloadData()
            try? fetchedResultsController.performFetch()
        }
    }
    @IBAction func reloadData(_ sender: Any) {
        if let results = fetchedResultsController.fetchedObjects{
            for objects in results{
                    dataController.viewContext.delete(objects)
                    try? dataController.viewContext.save()
            }
        }
        _ = NetworkingFlickr(coords: pinRecieved, dataaController: dataController, pinToSave: pinSaved)
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            return
        }
    }
    
}

