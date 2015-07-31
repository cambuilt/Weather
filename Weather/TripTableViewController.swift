//
//  TripTableViewController.swift
//  Weather
//
//  Created by Cameron Conway on 7/30/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//

import UIKit

class TripTableViewController : UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        do {
            try print(getWeather())
        } catch {
            print(error)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        
        return cell
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather() throws -> String
    {
        let secondsInADay = 86400.0

        let apiKey = "10851ae3ab8887d6"
        let urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/DC/Washington.json"
        var weatherType = ""
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
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                    let forecastday = ((json["forecast"] as! NSDictionary)["txt_forecast"] as! NSDictionary)["forecastday"] as! NSArray
                    let dayIcon = (forecastday[index] as! NSDictionary)["icon"] as! String
                    let nightIcon = (forecastday[index + 1] as! NSDictionary)["icon"] as! String
                    
                    print(dayIcon)
                    print(nightIcon)
                    weatherType = "cloudy"
                    
                } catch {
                    // handle error
                }
                
            }
            
            dataTask.resume()
        }
        
        return weatherType
    }
    
}