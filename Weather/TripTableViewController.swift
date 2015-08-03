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
    let loadMode = true
    var alert:UIAlertController!
    var chosenDate:NSDate!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        chosenDate = NSDate().dateByAddingTimeInterval(secondsInADay * 3)
        
        if loadMode == true {
            loadTrips()
        }

        getTrips()

        tableView.sectionHeaderHeight = 64
        tableView.rowHeight = 60
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Kitty Hawk", state: "NC", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Freeport", state: "BS", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Barrow", state: "AK", startDate: "08/03/2015", endDate: "08/15/2015")
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
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEEE, MMMM d"
        dateFormat.timeZone = NSTimeZone.localTimeZone()
        let stringDate = dateFormat.stringFromDate(chosenDate)
        let dateLabel = UILabel(frame: CGRect(x: 240, y: 24, width: 220, height: 32))
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.text = stringDate
        dateLabel.font = UIFont.boldSystemFontOfSize(12.0)
        sectionHeaderView.addSubview(dateLabel)
        
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
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TripCell")
        cell.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
        cell.textLabel?.text = "\(tripArray[indexPath.row].city!), \(tripArray[indexPath.row].state!)"
        
        if indexPath.row < weatherArray.count {
            let dayImageView = UIImageView(image: UIImage(named: weatherArray[indexPath.row]["Day"]!))
            dayImageView.frame = CGRect(x: 250, y: -3, width: 40, height: 40)
            
            let nightImageBackgroundView = UIImageView(image: UIImage(named: "nightbackground"))
            nightImageBackgroundView.alpha = 0.3
            nightImageBackgroundView.frame = CGRect(x: 307, y: -3, width: 40, height: 40)
            
            let nightImageView = UIImageView(image: UIImage(named: weatherArray[indexPath.row]["Night"]!))
            nightImageView.frame = CGRect(x: 307, y: -3, width: 40, height: 40)
            
            let highTempLabel = UILabel(frame: CGRect(x: 250, y: -30, width: 60, height: 40))
            highTempLabel.font = UIFont.systemFontOfSize(12)
            let high = weatherArray[indexPath.row]["High"]!
            highTempLabel.text = "High:\(high)"
            
            let lowTempLabel = UILabel(frame: CGRect(x: 305, y: -30, width: 60, height: 40))
            lowTempLabel.font = UIFont.systemFontOfSize(12)
            let low = weatherArray[indexPath.row]["Low"]!
            lowTempLabel.text = "Low:\(low)"
            
            cell.textLabel?.addSubview(dayImageView)
            cell.textLabel?.addSubview(nightImageBackgroundView)
            cell.textLabel?.addSubview(nightImageView)
            cell.textLabel?.addSubview(highTempLabel)
            cell.textLabel?.addSubview(lowTempLabel)

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
        let startDate = NSDate()
        let endDate = NSDate().dateByAddingTimeInterval(secondsInADay * 7)

        if chosenDate == chosenDate.laterDate(startDate) && chosenDate != endDate.laterDate(chosenDate) {
            let fromDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: startDate)
            let toDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: chosenDate)
            let index = (toDays - fromDays) * 2
            
            guard let url = NSURL(string: urlString) else {
                throw NSError(domain: "Weather", code: -1, userInfo: nil)
            }
            
            let dataTask = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                do {
                    if let jsonData = data {
                        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
                        
                        guard let forecast = json!["forecast"] as? NSDictionary,
                            let simpleforecast = forecast["simpleforecast"] as? NSDictionary,
                            let simpleforecastday = simpleforecast["forecastday"] as? NSArray,
                            let txt_forecast = forecast["txt_forecast"] as? NSDictionary,
                            let txt_forecastday = txt_forecast["forecastday"] as? NSArray
                        else {
                            self.showError("10 day forecast is not available for \(trip.city!), \(trip.state!).")
                            return
                        }
                        
                        if index < simpleforecastday.count {
                            let dayIcon = (txt_forecastday[index * 2] as! NSDictionary)["icon"] as! String
                            let nightIcon = (txt_forecastday[index * 2 + 1] as! NSDictionary)["icon"] as! String
                            let highTemp = ((simpleforecastday[index] as! NSDictionary)["high"] as! NSDictionary)["fahrenheit"] as! String
                            let lowTemp = ((simpleforecastday[index] as! NSDictionary)["low"] as! NSDictionary)["fahrenheit"] as! String
                            self.weatherArray.append(["Day":dayIcon,"Night":nightIcon,"High":highTemp,"Low":lowTemp])
                            self.tripArray.append(trip)
                            
                             if self.tripArray.count == self.tripCount {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView.reloadData()
                                })
                                
                             }
                        }
                    } else {
                        // errorMessage = "json is nil"
                    }
                } catch {
                    print(error)
                }
            }
            
            dataTask.resume()
        }
    }
    
    func showError(message:String)
    {
        alert = UIAlertController(title: "Weather Message", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let delay = 4.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            self.dismissAlert()
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func dismissAlert()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}