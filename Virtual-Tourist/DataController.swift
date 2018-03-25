//
//  DataController.swift
//  Virtual-Tourist
//
//  Created by Sultan on 20/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer : NSPersistentContainer
    
    init(modelName : String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    var viewContext : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    
    func load(completition : (() -> Void)? = nil){
        persistentContainer.loadPersistentStores{ storeDescription,error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completition?()
        }
    }
    
    
    
}
