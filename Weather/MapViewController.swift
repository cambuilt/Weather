//
//  MapViewController.swift
//  Weather
//
//  Created by Cameron Conway on 8/5/15.
//  Copyright © 2015 Cam-Built Programming Plus. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController : UIViewController, SFSafariViewControllerDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    let zoomDelta = 0.1

    func centerMapOnCity(locationName:String)
    {
        CLGeocoder().geocodeAddressString(locationName) { (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            if error == nil && placemarks != nil && placemarks!.count > 0 {
                let placemark:CLPlacemark = placemarks![0]
                
                if let loc = placemark.location {
                    let coordinate = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    var points = [MKMapPointForCoordinate(coordinate)]
                    let mapRect = MKPolygon(points: &points, count: 1).boundingMapRect
                    var region = MKCoordinateRegionForMapRect(mapRect)
                    region.span.latitudeDelta = self.zoomDelta
                    region.span.longitudeDelta = self.zoomDelta
                    self.mapView?.setRegion(region, animated: true)
                }
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func didTapWeb(sender: AnyObject)
    {
        let criteria = navigationItem.title!.stringByAddingPercentEncodingWithAllowedCharacters(.alphanumericCharacterSet())!
        let url = "https://duckduckgo.com/?q=\(criteria)"
        let safariViewController = SFSafariViewController(URL: NSURL(string: url)!)
        safariViewController.delegate = self
        presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
