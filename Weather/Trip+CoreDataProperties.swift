//
//  Trip+CoreDataProperties.swift
//  Weather
//
//  Created by Cameron Conway on 7/30/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Trip
{
    @NSManaged var city: String
    @NSManaged var countryCode: String
    @NSManaged var state: String
    @NSManaged var startDate: NSDate?
    @NSManaged var endDate: NSDate?
}
