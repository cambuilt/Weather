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
    var tripCount = 0
    var weatherArray = [[String:String]]()
    var weatherCounter = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // loadTrips()
        getTrips()
        tableView.sectionHeaderHeight = 64
        tableView.rowHeight = 60
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", startDate: "08/01/2015", endDate: "08/07/2015")
            try Trip.addTrip("Kitty Hawk", state: "NC", startDate: "08/15/2015", endDate: "08/27/2015")
            try Trip.addTrip("Freeport", state: "BS", startDate: "08/15/2015", endDate: "08/27/2015")
        } catch {
            print(error)
        }
    }
    
    func getTrips()
    {
        let request = NSFetchRequest(entityName: "Trip")
        
        do {
            let trips = try managedObjectContext.executeFetchRequest(request) as! [Trip]
            tripCount = trips.count
            weatherCounter = 0
            
            for trip in trips {
                do {
                    try getWeather(trip)
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 3, width: 320, height: 30))
        sectionHeaderView.backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0)
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 24, width: 220, height: 32))
        headerLabel.textColor = UIColor.whiteColor()
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
        print(tripArray.count)
        return tripArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TripCell")
        cell.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        cell.textLabel?.text = "\(tripArray[indexPath.row].city!), \(tripArray[indexPath.row].state!)"
        
        if indexPath.row < weatherArray.count {
            let dayImageView = UIImageView(image: UIImage(named: weatherArray[indexPath.row]["Day"]!))
            dayImageView.frame = CGRect(x: 250, y: -20, width: 50, height: 50)
            let nightImageView = UIImageView(image: UIImage(named: weatherArray[indexPath.row]["Night"]!))
            nightImageView.frame = CGRect(x: 300, y: -20, width: 50, height: 50)
            cell.textLabel?.addSubview(dayImageView)
            cell.textLabel?.addSubview(nightImageView)
//         	cell.detailTextLabel?.text = weatherArray[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather(trip:Trip) throws
    {
        let apiKey = "10851ae3ab8887d6"
        let urlCity = trip.city!.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/\(trip.state!)/\(urlCity).json"
//        let urlString = "http://www.microsoft.com"
        var errorMessage = ""
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
                        guard let forecastday = ((json!["forecast"] as! NSDictionary)["txt_forecast"] as! NSDictionary)["forecastday"] as? NSArray else {
                            throw NSError(domain: "Weather", code: -1, userInfo: nil)
                        }
                        let dayIcon = (forecastday[index] as! NSDictionary)["icon"] as! String
                        let nightIcon = (forecastday[index + 1] as! NSDictionary)["icon"] as! String
                        self.weatherArray.append(["Day":dayIcon,"Night":nightIcon])
                        self.tripArray.append(trip)
                        
                        if self.tripArray.count == self.tripCount {
                            self.tableView.reloadData()
                        }
                    } else {
                        errorMessage = "json is nil"
                    }
                } catch {
                    print("getWeather error: \(error)")
                }
            }
            
            print(errorMessage)
            dataTask.resume()
        }
    }
}