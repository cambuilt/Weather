//
//  TripTableViewController.swift
//  Weather
//
//  Created by Cameron Conway on 7/30/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//

import UIKit
import CoreData

enum WeatherError : ErrorType
{
    case InvalidURL
    case InvalidJSON
    case MissingForecast
    case WeatherSiteUnreachable
}

class TripTableViewController : UITableViewController
{
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let secondsInADay = 86400.0
    var tripArray = [Trip]()
    var tripCount = 0
    var weatherArray = [[String:String]]()
    var loadMode = false
    var alert:UIAlertController!
    var chosenDate:NSDate!
    var alertShown = false
    let apiKey = "10851ae3ab8887d6"
    
    override func viewDidLoad()
    {
        chosenDate = NSDate().dateByAddingTimeInterval(secondsInADay * 3)
        
        if loadMode == true {
            loadTrips()
        } else {
            getTrips()
        }
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", countryCode: "US", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Kitty Hawk", state: "NC", countryCode: "US", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Freeport", state: "", countryCode: "BS", startDate: "08/03/2015", endDate: "08/15/2015")
            try Trip.addTrip("Barrow", state: "AK", countryCode: "US", startDate: "08/03/2015", endDate: "08/15/2015")
            // try Trip.addTrip("Nuuk", state: "", countryCode: "GL", startDate: "08/03/2015", endDate: "08/15/2015")
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
            
            for trip in trips {
                do {
                    self.tripArray.append(trip)
                    try getWeather(trip)
                } catch {
                    print("getWeather error: \(error)")
                }
            }
            
            tableView.reloadData()
            
        } catch {
            print("getTrips error: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 3, width: 320, height: 30))
        sectionHeaderView.backgroundColor = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
        let headerLabel = UILabel(frame: CGRect(x: 12, y: 5, width: 220, height: 32))
        headerLabel.textColor = UIColor.whiteColor()
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEEE, MMMM d"
        dateFormat.timeZone = NSTimeZone.localTimeZone()
        let stringDate = dateFormat.stringFromDate(chosenDate)
        headerLabel.text = stringDate
        headerLabel.font = UIFont.boldSystemFontOfSize(18.0)
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! TripCell
        cell.cityNameLabel.text = "\(tripArray[indexPath.row].city), \(tripArray[indexPath.row].state)"
        
        if indexPath.row < weatherArray.count {
            cell.weatherReportLabel.text = weatherArray[indexPath.row]["Text"]!
            cell.dayImageView.image = UIImage(named: weatherArray[indexPath.row]["Day"]!)
            cell.nightImageView.image = UIImage(named: weatherArray[indexPath.row]["Night"]!)
            let high = weatherArray[indexPath.row]["High"]!
            cell.highTempLabel.text = "High:\(high) - "
            let low = weatherArray[indexPath.row]["Low"]!
            cell.lowTempLabel.text = "Low:\(low)"
        } else {
            cell.weatherReportLabel.text = ""
            cell.highTempLabel.text = ""
            cell.lowTempLabel.text = ""
            cell.nightBackImageView.hidden = true
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        performSegueWithIdentifier("MapSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "MapSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let locationName = "\(tripArray[indexPath.row].city), \(tripArray[indexPath.row].state)"
                if let mapViewController = segue.destinationViewController as? MapViewController {
                    mapViewController.navigationItem.title = locationName
                    mapViewController.centerMapOnCity(locationName)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather(trip:Trip) throws
    {
        let urlCity = trip.city.stringByReplacingOccurrencesOfString(" ", withString: "_")
        var urlString = ""
        
        if trip.state.characters.count > 0 {
            urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/\(trip.state)/\(urlCity).json"
        } else {
            urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/\(trip.countryCode)/\(urlCity).json"
        }
        
//        let urlString = "http://www.microsoft.com"
        let startDate = NSDate()
        let endDate = NSDate().dateByAddingTimeInterval(secondsInADay * 7)

        if chosenDate == chosenDate.laterDate(startDate) && chosenDate != endDate.laterDate(chosenDate) {
            let fromDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: startDate)
            let toDays = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit:.Era, forDate: chosenDate)
            let index = (toDays - fromDays) * 2
            
            guard let url = NSURL(string: urlString) else {
                throw WeatherError.InvalidURL
            }
            
            let dataTask = NSURLSession(configuration:.defaultSessionConfiguration()).dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                do {
                    if let jsonData = data {
                        let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
                        
                        guard let forecast = json!["forecast"] as? NSDictionary,
                            let simpleforecast = forecast["simpleforecast"] as? NSDictionary,
                            let simpleforecastday = simpleforecast["forecastday"] as? NSArray,
                            let txt_forecast = forecast["txt_forecast"] as? NSDictionary,
                            let txt_forecastday = txt_forecast["forecastday"] as? NSArray
                        else {
                            throw WeatherError.MissingForecast
                        }
                        
                        if index < simpleforecastday.count {
                            let dayIcon = (txt_forecastday[index * 2] as! NSDictionary)["icon"] as! String
                            let nightIcon = (txt_forecastday[index * 2 + 1] as! NSDictionary)["icon"] as! String
                            let highTemp = ((simpleforecastday[index] as! NSDictionary)["high"] as! NSDictionary)["fahrenheit"] as! String
                            let lowTemp = ((simpleforecastday[index] as! NSDictionary)["low"] as! NSDictionary)["fahrenheit"] as! String
                            let fcttext = (txt_forecastday[index * 2] as! NSDictionary)["fcttext"] as! String
                            self.weatherArray.append(["Day":dayIcon,"Night":nightIcon,"High":highTemp,"Low":lowTemp,"Text":fcttext])
                            
                            if self.tripArray.count == self.tripCount {
                               dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                   self.tableView.reloadData()
                               })
                            }
                        }
                    } else {
                        throw error!
                    }
//                } catch WeatherError.InvalidJSON {
//                    print("Special actions for this error.")
                } catch {
                    self.showError(error)
                }
            }
            
            dataTask.resume()
        }
    }
    
    func showError(error:ErrorType)
    {
        if alertShown == false {
            alertShown = true
            var message = ""
            
            switch error {
                case WeatherError.InvalidJSON:
                    message = "The URL returned invalid JSON."
                case WeatherError.MissingForecast:
                    message = "There is no 10 day forecast for some of your cities."
                case WeatherError.WeatherSiteUnreachable:
                    message = "Weather information is unavailable."
                default:
                    message = (error as NSError).localizedDescription
            }
            
            alert = UIAlertController(title: "Weather Message", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.dismissAlert()
            }
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func dismissAlert()
    {
        alertShown = false
        dismissViewControllerAnimated(true, completion: nil)
    }
}