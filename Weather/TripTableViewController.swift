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
        
        let apiKey = "10851ae3ab8887d6"
        let urlString = "http://api.wunderground.com/api/\(apiKey)/forecast10day/q/DC/Washington.json"
        var weatherType = ""

        guard let url = NSURL(string: urlString) else {
            throw NSError(domain: "Weather", code: -1, userInfo: nil)
        }
        
        let request = NSURLRequest(URL: url)
    
        let dataTask = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                let forecast = (json["forecast"] as! NSDictionary)["txt_forecast"] as! NSDictionary
                print(json)
                print("test")
                weatherType = "cloudy"

            } catch {
                // handle error
            }

        }
        
        dataTask.resume()
        
        print(apiKey)
        
        return weatherType
    }
    
}