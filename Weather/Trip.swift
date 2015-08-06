//
//  Trip.swift
//  Weather
//
//  Created by Cameron Conway on 7/30/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//

import UIKit
import CoreData

@objc(Trip)
class Trip: NSManagedObject
{
    class func addTrip(city:String, state:String, countryCode:String, startDate:String, endDate:String) throws -> Trip
    {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let trip = NSEntityDescription.insertNewObjectForEntityForName("Trip", inManagedObjectContext: managedObjectContext) as! Trip
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/YYYY"
        trip.city = city
        trip.state = state
        trip.countryCode = countryCode
        trip.startDate = dateFormat.dateFromString(startDate)
        trip.endDate = dateFormat.dateFromString(endDate)
        
        do {
            try managedObjectContext.save()
        } catch {
            throw NSError(domain: "Trip", code: -1, userInfo: ["Message":"Save of trip failed."])
        }
        
        return trip
    }

}
