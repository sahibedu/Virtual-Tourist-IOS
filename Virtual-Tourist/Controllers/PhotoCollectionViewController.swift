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

class PhotoCollectionViewController : UIViewController,NSFetchedResultsControllerDelegate ,UICollectionViewDataSource,UICollectionViewDelegate{
    
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
        if fetchedResultsController.fetchedObjects == nil{
            _ = NetworkingFlickr(coords: pinRecieved, dataaController: dataController, pinToSave: pinSaved)
        }

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
        do{
            try fetchedResultsController.performFetch()
            print("Performed Fetch")
            for objects in fetchedResultsController.fetchedObjects!{
                print(objects.url!)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let prototypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionCell
        prototypeCell.initWithPhoto(photoURL: (fetchedResultsController.fetchedObjects![indexPath.row]).url!)
        return prototypeCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (navigationItem.rightBarButtonItem?.title == "Done"){
                print("Call Delete Function")
        }
    }
}
