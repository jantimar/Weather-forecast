//
//  ForecastViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 7.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import CoreLocation

class ForecastViewController: UITableViewController, CLLocationManagerDelegate {
    
    
    // MARK: Properties
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private lazy var locationManager:CLLocationManager = {        // lazy initialization for location
        let lazilyLocationManager = CLLocationManager()
        lazilyLocationManager.delegate = self
        lazilyLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        lazilyLocationManager.requestAlwaysAuthorization()
        return lazilyLocationManager
        }()
    
    private var forecasts = OpenWeatheAPIManager.Forecasts() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.reloadData()
                self.title = self.forecasts.city
            })
        }
    }
    
    
    private var tempratureConverter = TempratureConverter()
    
    // MARK: Life cycle methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let useCurrentPositionForWeather = defaults.boolForKey("useCurrentPositionForWeather")
        
        if useCurrentPositionForWeather
        {
            // load weather forecast from saved coordinate
            
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Locations delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            openWeatherAPIManager.asynchronlyGetForecast(6, longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, loadedForecasts: { (forecasts) -> () in
                
                self.forecasts = forecasts
                manager.stopUpdatingLocation()  // only one result is suitable
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.forecast.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForecastTableViewCelldentifire", forIndexPath: indexPath) as! UITableViewCell
        
        if let forecastCell = cell as? ForecastTableViewCell {
            let dayForecast = forecasts.forecast[indexPath.row]
            
            // set temprature in they format
            if defaults.stringForKey("TempratureUnit") == "Celsius"{
                forecastCell.tempratureLabel.text = String(format:"%d", self.tempratureConverter.convertTemperatures(dayForecast.tempratue,  source:"Kelvin", target:"Celsius"))
            } else if self.defaults.stringForKey("TempratureUnit") == "Kelvin" {
                forecastCell.tempratureLabel.text = String(format:"%gK", dayForecast.tempratue)
            } else {
                forecastCell.tempratureLabel.text = String(format:"%g℉", self.tempratureConverter.convertTemperatures( dayForecast.tempratue,  source:"Kelvin", target:"Fahrenheit"))
            }
            // set image when description contain key word
            let lowercaseDescription = dayForecast.description.lowercaseString
            if lowercaseDescription.rangeOfString("cloud") != nil {
                forecastCell.weatherImageView.image = UIImage(named: "Cloudy_Big")
            } else if lowercaseDescription.rangeOfString("light") != nil {
                forecastCell.weatherImageView.image = UIImage(named: "Lightning_Big")
            } else if lowercaseDescription.rangeOfString("wind") != nil {
                forecastCell.weatherImageView.image = UIImage(named: "WInd_Big")
            } else {
                forecastCell.weatherImageView.image = UIImage(named: "Sun_Big")
            }
            
            forecastCell.weatherDescriptionLabel.text = dayForecast.description
            
            forecastCell.dayLabel.text = dayNameFromToday(indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92.0
    }
    
    // MAKR: Help methods
    
    private func dayNameFromToday(daysFromToday: Int) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = NSDate()
        return dateFormatter.stringFromDate(today.dateByAddingTimeInterval(NSTimeInterval(60*60*24*daysFromToday)))
    }
}
