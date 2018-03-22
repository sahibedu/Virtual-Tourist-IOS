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
        getNetworkRequest()
    }
    
    func setupInitialView(){
        let coordinate = CLLocationCoordinate2D(latitude: pinRecieved.coordinate.latitude, longitude: pinRecieved.coordinate.longitude)
        let span = MKCoordinateSpanMake(pinRecieved.coordinate.latitude, pinRecieved.coordinate.longitude)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated: true)
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
        
        let session = URLSession.shared
        let request = URLRequest(url: FlickrURL(parameters: methodParameters as [String : AnyObject]))
        let task = session.dataTask(with: request) {
            (data,request,error) in
            if (error == nil){
                let parsedResult : [String : AnyObject]
                do{
                    try parsedResult = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                    print(parsedResult)
                } catch {
                    print("Error in Fetching Results")
                }
            }
        }
        task.resume()
    }
    
    
    func getbbox() -> String{
        
        let minimumLon = max(pinRecieved.coordinate.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(pinRecieved.coordinate.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(pinRecieved.coordinate.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(pinRecieved.coordinate.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func setUpURL(){
        
        
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
