//
//  City.swift
//  
//
//  Created by Jan Timar on 8.5.2015.
//
//

import Foundation
import CoreData

@objc(City)
class City: NSManagedObject {

    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var name: String
    @NSManaged var countryCode: String

}
