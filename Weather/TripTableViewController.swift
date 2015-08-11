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
    var tripArray = [Trip]()
    var tripCount = 0
    var weatherDictionary = [String:[[String:String]]]()
    var loadMode = false
    var alert:UIAlertController!
    var chosenDate:NSDate!
    var alertShown = false
    let apiKey = "68be623fd62b72cc6068bec1815deae4"

    override func viewDidLoad()
    {
        let secondsInADay = 86400.0
        chosenDate = NSDate().dateByAddingTimeInterval(secondsInADay)
        
        if loadMode == true {
            loadTrips()
        } else {
            getTrips()
        }
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", country: "US", startDate: "20150812", endDate: "20150815", latitude: 40.713054, longitude: -74.007228)
            try Trip.addTrip("Kitty Hawk", state: "NC", country: "US", startDate: "20150812", endDate: "20150815", latitude: 36.066357, longitude: -75.693523)
            try Trip.addTrip("Freeport", state: "", country: "The Bahamas", startDate: "20150812", endDate: "20150815", latitude: 26.548167, longitude: -78.696324)
            try Trip.addTrip("Barrow", state: "AK", country: "US", startDate: "20150812", endDate: "20150815", latitude: 71.298000, longitude: -156.766389)
            try Trip.addTrip("Nuuk", state: "", country: "Greenland", startDate: "20150812", endDate: "20150815", latitude: 64.183877, longitude: -51.707876)
            try Trip.addTrip("Washington", state: "DC", country: "US", startDate: "20150812", endDate: "20150815", latitude: 38.892062, longitude: -77.019912)
            try Trip.addTrip("Hong Kong", state: "", country: "China", startDate: "20150812", endDate: "20150815", latitude: 22.358535, longitude: 114.142271)
            try Trip.addTrip("Moscow", state: "", country: "Russia", startDate: "20150812", endDate: "20150815", latitude: 55.752222, longitude: 37.615556)
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
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
        let tripKey:String
        
        if tripArray[indexPath.row].state.characters.count == 0 {
            tripKey = "\(tripArray[indexPath.row].city), \(tripArray[indexPath.row].country)"
        } else {
            tripKey = "\(tripArray[indexPath.row].city), \(tripArray[indexPath.row].state)"
        }
        
        cell.cityNameLabel.text = tripKey
        
        if let weatherAttributes = weatherDictionary[tripKey] as [[String:String]]? {
            if indexPath.row < weatherDictionary.keys.count {
                for index in 0..<weatherAttributes.count {
                    let tempLabel = cell.viewWithTag(index * 3 + 1) as! UILabel
                    tempLabel.text = weatherAttributes[index]["TempAvg"]! + "°F"
                    let imageView = cell.viewWithTag(index * 3 + 2) as! UIImageView
                    imageView.image = UIImage(named: weatherAttributes[index]["Icon"]!)
                    let timeLabel = cell.viewWithTag(index * 3 + 3) as! UILabel
                    timeLabel.text = weatherAttributes[index]["Time"]!
                }
            } else {
                for index in 0..<weatherAttributes.count {
                    let tempLabel = cell.viewWithTag(index * 3 + 1) as! UILabel
                    tempLabel.text = ""
                    let imageView = cell.viewWithTag(index * 3 + 2) as! UIImageView
                    imageView.image = nil
                    let timeLabel = cell.viewWithTag(index * 3 + 3) as! UILabel
                    timeLabel.text = ""
                }
            }
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
        var urlString = ""
        urlString = "http://api.openweathermap.org/data/2.5/forecast/q?lat=\(trip.latitude!.stringValue)&lon=\(trip.longitude!.stringValue)&cnt=32&units=imperial&APPID=\(apiKey)"
//      urlString = "http://www.microsoft.com"

        guard let url = NSURL(string: urlString) else {
            throw WeatherError.InvalidURL
        }
        
        let dataTask = NSURLSession(configuration:.defaultSessionConfiguration()).dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                if let jsonData = data {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
                    
                    if let list = json!["list"] as? [NSDictionary] {
                        var elementArray = [[String:String]]()
                        let dateFormat = NSDateFormatter()
                        dateFormat.dateFormat = "MM/dd/YYYY"
                        dateFormat.timeZone = NSTimeZone.localTimeZone()
                        let tripDateString = dateFormat.stringFromDate(trip.startDate!)
                        let tripKey:String
                        dateFormat.dateFormat = "MM/dd/YYYY h aaa"
                        
                        if trip.state.characters.count == 0 {
                            tripKey = "\(trip.city), \(trip.country)"
                        } else {
                            tripKey = "\(trip.city), \(trip.state)"
                        }
                        
                        for item:NSDictionary in list {
                            if let itemDateUnix = item["dt"] as? NSNumber {
                            	let itemDate = NSDate(timeIntervalSince1970: itemDateUnix.doubleValue)
                                dateFormat.dateFormat = "MM/dd/YYYY"
                                let itemDateString = dateFormat.stringFromDate(itemDate)
                                if itemDateString == tripDateString && elementArray.count < 6 {
                                    guard let main = item["main"] as? NSDictionary,
                                      	let tempMax = main["temp_max"] as? NSNumber,
                                       	let tempMin = main["temp_min"] as? NSNumber,
                                        let weatherArray = item["weather"] as? NSArray,
                                     	let weatherItem = weatherArray[0] as? NSDictionary,
                                       	let weatherDesc = weatherItem["description"] as? String,
                                        let weatherIcon = weatherItem["icon"] as? String
                                    else {
                                        throw WeatherError.MissingForecast
                                    }
                                    
                                    dateFormat.dateFormat = "h aaa"
                                    let time = dateFormat.stringFromDate(itemDate)
                                    let tempAvg = (tempMax.integerValue - (tempMax.integerValue - tempMin.integerValue) / 2 as NSNumber).stringValue
                                    
                                    if itemDate.timeIntervalSinceDate(trip.startDate!) > 18000 {
                                    	elementArray.append(["Time":time,"TempAvg":tempAvg,"Description":weatherDesc,"Icon":weatherIcon])
                                    }
                                }
                            }
                        }
                        
                        if elementArray.count > 0 {
                        	self.weatherDictionary[tripKey] = elementArray
                        }
                	}
                    
                    if self.tripArray.count == self.tripCount {
                       dispatch_async(dispatch_get_main_queue(), { () -> Void in
                           self.tableView.reloadData()
                       })
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