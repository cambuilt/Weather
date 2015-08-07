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
    var weatherArray = [[String:String]]()
    var loadMode = false
    var alert:UIAlertController!
    var chosenDate:NSDate!
    var alertShown = false
    let apiKey = "68be623fd62b72cc6068bec1815deae4"
    
    override func viewDidLoad()
    {
        chosenDate = NSDate()
        
        if loadMode == true {
            loadTrips()
        } else {
            getTrips()
        }
    }

    func loadTrips()
    {
        do {
            try Trip.addTrip("New York", state: "NY", country: "US", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 40.713054, longitude: -74.007228)
            try Trip.addTrip("Kitty Hawk", state: "NC", country: "US", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 36.066357, longitude: -75.693523)
            try Trip.addTrip("Freeport", state: "", country: "The Bahamas", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 26.548167, longitude: -78.696324)
            try Trip.addTrip("Barrow", state: "AK", country: "US", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 71.298000, longitude: -156.766389)
            try Trip.addTrip("Nuuk", state: "", country: "Greenland", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 64.183877, longitude: -51.707876)
            try Trip.addTrip("Hong Kong", state: "", country: "China", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 22.358535, longitude: 114.142271)
            try Trip.addTrip("Moscow", state: "", country: "Russia", startDate: "08/03/2015", endDate: "08/15/2015", latitude: 55.752222, longitude: 37.615556)
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
        cell.cityNameLabel.text = "\(tripArray[indexPath.row].city), \(tripArray[indexPath.row].state)"
        
        if indexPath.row < weatherArray.count {
            cell.weatherReportLabel.text = weatherArray[indexPath.row]["Text"]!
            cell.dayImageView.image = UIImage(named: weatherArray[indexPath.row]["Day"]!)
            cell.nightImageView.image = UIImage(named: weatherArray[indexPath.row]["Night"]!)
            let high = weatherArray[indexPath.row]["High"]!.componentsSeparatedByCharactersInSet(NSCharacterSet.punctuationCharacterSet())[0]
            cell.highTempLabel.text = "High:\(high) - "
            let low = weatherArray[indexPath.row]["Low"]!.componentsSeparatedByCharactersInSet(NSCharacterSet.punctuationCharacterSet())[0]
            cell.lowTempLabel.text = "Low:\(low)"
        } else {
            cell.weatherReportLabel.text = ""
            cell.highTempLabel.text = ""
            cell.lowTempLabel.text = ""
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
    
    func getWeatherHC(trip:Trip) throws
    {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/YY"
        dateFormat.timeZone = NSTimeZone.localTimeZone()
        let stringDate = dateFormat.stringFromDate(chosenDate)
        
        weatherArray.append(["Day":"clear","Night":"nt_cloudy","High":"76","Low":"64","Text":"Weather report for \(stringDate) will be sunny all day and then when night falls, clouds will roll in and sometimes block the moon. This will anger the moon who will push them away!"])
    }
    
    func getWeather(trip:Trip) throws
    {
        var urlString = ""
        urlString = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(trip.latitude!.stringValue)&lon=\(trip.longitude!.stringValue)&cnt=16&units=imperial&APPID=\(apiKey)"
//      urlString = "http://www.microsoft.com"

        guard let url = NSURL(string: urlString) else {
            throw WeatherError.InvalidURL
        }
        
        let dataTask = NSURLSession(configuration:.defaultSessionConfiguration()).dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                if let jsonData = data {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary
                    
                    guard let list = json!["list"] as? NSArray,
                          let item1 = list[0] as? NSDictionary,
                          let item2 = list[1] as? NSDictionary,
                    	  let time1 = item1["dt"] as? NSNumber,
	                      let time2 = item2["dt"] as? NSNumber,
                          let temps1 = item1["temp"] as? NSDictionary,
                          let temps2 = item2["temp"] as? NSDictionary,
                    	  let tempMax1 = temps1["max"] as? NSNumber,
                       	  let tempMin1 = temps1["min"] as? NSNumber,
                          let tempMax2 = temps2["max"] as? NSNumber,
                          let tempMin2 = temps2["min"] as? NSNumber,
                          let weatherArray1 = item1["weather"] as? NSArray,
		                  let weatherArray2 = item2["weather"] as? NSArray,
                    	  let weatherItem1 = weatherArray1[0] as? NSDictionary,
                       	  let weatherItem2 = weatherArray2[0] as? NSDictionary,
                    	  let weatherDesc1 = weatherItem1["description"] as? String,
	                      let weatherDesc2 = weatherItem2["description"] as? String,
                          let weatherIcon1 = weatherItem1["icon"] as? String,
                          let weatherIcon2 = weatherItem2["icon"] as? String
                    else {
                        throw WeatherError.MissingForecast
                    }
                    
                    self.weatherArray.append(["Day":weatherIcon1,"Night":weatherIcon2,"High":tempMax1.stringValue,"Low":tempMin1.stringValue,"Text":"\(weatherDesc1)\n\(weatherDesc2)"])
                    
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