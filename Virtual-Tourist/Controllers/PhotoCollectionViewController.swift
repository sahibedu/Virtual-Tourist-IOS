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

class PhotoCollectionViewController : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadDataBtn: UIButton!
    
    var dataController : DataController!
    var pinRecieved : MKAnnotation!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        getNetworkRequest()
        collectionView.delegate = self
    }
    
    func setupInitialView(){
        mapView.addAnnotation(pinRecieved)
        mapView.setRegion(MKCoordinateRegionMake(pinRecieved.coordinate, MKCoordinateSpanMake(0.05, 0.05))  , animated: true)
        
    }
    
    fileprivate func networkSessio(_ methodParameters: [String : String]) {
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
                    let randomPhotoArray = photoArray![0] as? [String:AnyObject]
                    let imageURLString = randomPhotoArray![Constants.FlickrResponseKeys.MediumURL] as! String
                    let imageURL = URL(string: imageURLString)
                    
                    
                    
                } catch {
                    print("Error in Fetching Results")
                }
                
            }//Check For Error Ends Here
            
        }//Data Request Ends Here
        
        task.resume()
    }
    
    func getNetworkRequest(){
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: getbbox(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        networkSessio(methodParameters)
    }
    
    
    func getbbox() -> String{
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let protypeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! CollectionCell
        return protypeCell
    }
    
    
    
    
}
