//
//  NetworkingFlickr.swift
//  Virtual-Tourist
//
//  Created by Sultan on 24/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import Foundation
import  MapKit
import CoreData

class NetworkingFlickr : NSFetchedResultsController<Photos>{
    
    var fetchedResultsController:NSFetchedResultsController<Photos>!
    var dataController : DataController!
    
    init(coords : MKAnnotation,dataaController : DataController,pinToSave : Pin){
        super.init()
        //print("Networking Flickr Called")
        dataController = dataaController
            //print("Entered Main queue Starting getnetworkrequest")
            self.getNetworkRequest(pinRecieved: coords, pinToSave: pinToSave)
            //print("Starting Save")
            try? self.dataController.viewContext.save()
            //print("starting fetch Request")
        self.setupFetchRequest(dataaController,pintoSave: pinToSave)
            //print("Exiting Main queue")
    }
    
    
    fileprivate func setupFetchRequest(_ dataaController: DataController,pintoSave : Pin) {
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin==%@", argumentArray: [pintoSave])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataaController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func SavePinToCD(photoURLToSave : String,pinToSave : Pin){
        let photoToSave = Photos(context: dataController.viewContext)
        photoToSave.url = photoURLToSave
        photoToSave.pin = pinToSave
        try? dataController.viewContext.save()
    }
    
    fileprivate func networkSessio(_ methodParameters: [String : String],coords : MKAnnotation,pinToSave : Pin) {
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURL(parameters: methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) {
            (data,request,error) in
            if (error == nil){
                let parsedResult : [String : AnyObject]!
                do{
                    try parsedResult = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject]
                    let photoArray = photosDictionary![Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
                    for _ in 0...10{
                        let randomNo = Int(arc4random_uniform(UInt32((photoArray?.count)!-2)))
                        let randomPhotoArray = photoArray![randomNo] as? [String:AnyObject]
                        let imageURLString = randomPhotoArray![Constants.FlickrResponseKeys.MediumURL] as! String
                        self.SavePinToCD(photoURLToSave: imageURLString, pinToSave: pinToSave)
                    }
                    
                } catch {
                    print("Error in Fetching Results")
                }
                
            }//Check For Error Ends Here
        }//Data Request Ends Here
        task.resume()
        
    }
    
    func getNetworkRequest(pinRecieved : MKAnnotation,pinToSave : Pin){
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: getbbox(pinRecieved: pinRecieved),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        networkSessio(methodParameters, coords: pinRecieved, pinToSave: pinToSave)
    }
    
    func getbbox(pinRecieved : MKAnnotation) -> String{
        
        let minimumLon = max(pinRecieved.coordinate.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(pinRecieved.coordinate.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(pinRecieved.coordinate.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(pinRecieved.coordinate.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func FlickrURL(parameters : [String : AnyObject]) -> URL{
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.Flickr.APIScheme
        urlComponents.host = Constants.Flickr.APIHost
        urlComponents.path = Constants.Flickr.APIPath
        urlComponents.queryItems = [URLQueryItem]()
        
        for(key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems?.append(queryItem)
        }
        return urlComponents.url!
    }
    
}
