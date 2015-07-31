//
//  TripTableViewController.swift
//  Weather
//
//  Created by Cameron Conway on 7/30/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//

import UIKit
import CoreData

class TripTableViewController : UITableViewController
{
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let secondsInADay = 86400.0
    var tripArray = [Trip]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // loadTrips()
        getTrips()
        tableView.sectionHeaderHeight = 64
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", startDate: "08/01/2015", endDate: "08/07/2015")
            try Trip.addTrip("Kitty Hawk", state: "NC", startDate: "08/15/2015", endDate: "08/27/2015")
        } catch {
            print(error)
        }
    }
    
    func getTrips()
    {
        let request = NSFetchRequest(entityName: "Trip")
        
        do {
            tripArray = try managedObjectContext.executeFetchRequest(request) as! [Trip]
        } catch {
            print(error)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 3, width: 320, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 24, width: 220, height: 32))
        headerLabel.text = "Trips"
        headerLabel.font = UIFont.boldSystemFontOfSize(20.0)
        sectionHeaderView.addSubview(headerLabel)
        
        return sectionHeaderView
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tripArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = "\(tripArray[indexPath.row].city!), \(tripArray[indexPath.row].state!)"
        
        return cell
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather() throws -> String
    {


        let apiKey = "10851ae3ab8887d6"
        let urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/DC/Washington.json"
//        let urlString = "http://www.microsoft.com"
        var weatherType = "blank"
        var errorMessage = "none"
        let thisDate = NSDate().dateByAddingTimeInterval(secondsInADay * 3)
        let startDate = NSDate()
        let endDate = NSDate().dateByAddingTimeInterval(secondsInADay * 7)

        if thisDate == thisDate.laterDate(startDate) && thisDate != endDate.laterDate(thisDate) {
            let fromDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: startDate)
            let toDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: thisDate)
            let index = (toDays - fromDays) * 2
            
            guard let url = NSURL(string: urlString) else {
                throw NSError(domain: "Weather", code: -1, userInfo: nil)
            }
            
            let dataTask = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                do {
                    if let jsonData = data {
                        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
                        let forecastday = ((json!["forecast"] as! NSDictionary)["txt_forecast"] as! NSDictionary)["forecastday"] as! NSArray
                        let dayIcon = (forecastday[index] as! NSDictionary)["icon"] as! String
                        let nightIcon = (forecastday[index + 1] as! NSDictionary)["icon"] as! String
                        
                        print(dayIcon)
                        print(nightIcon)
                        weatherType = "cloudy"
                    } else {
                        errorMessage = "json is nil"
                    }
                } catch {
                    print("getWeather error: \(error)")
                }
            }
            
            dataTask.resume()
            print(errorMessage)
        }
        
        return weatherType
    }
    
}