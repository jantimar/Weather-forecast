//
//  ForecastViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 7.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

class ForecastViewController: UITableViewController {
    
    
    // MARK: Properties
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
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
        
        let useSpecificPositionForWeather = defaults.boolForKey(Constants.UsingSpecificPositionKey)
        
        if useSpecificPositionForWeather
        { // load weather forecast from saved coordinate
            let latitude = defaults.doubleForKey(Constants.LatitudeKey)
            let longitude = defaults.doubleForKey(Constants.LongitudeKey)
            
            openWeatherAPIManager.asynchronlyGetForecast(6, longitude: longitude, latitude: latitude, loadedForecasts: { (forecasts) -> () in
                
                self.forecasts = forecasts
            })
        } else {
            var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
            if latitude != nil && longitude != nil {
                openWeatherAPIManager.asynchronlyGetForecast(6, longitude: longitude!, latitude: latitude!, loadedForecasts: { (forecasts) -> () in
                    self.forecasts = forecasts
                })
            }
            else {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: Constants.UserCoordinateKey, object: nil)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.UserCoordinateKey, object: nil)
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeGesture:")
        swipeRight.direction = .Right
        self.tableView?.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeGesture:")
        swipeLeft.direction = .Left
        self.tableView?.addGestureRecognizer(swipeLeft)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.forecast.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TempretureCelldentifire, forIndexPath: indexPath) as! UITableViewCell
        
        if let temperatureCell = cell as? TempretureTableViewCell {
            let dayForecast = forecasts.forecast[indexPath.row]
            
            // set temprature in format
            if let tempratureTypeRawValue = self.defaults.stringForKey(Constants.TempratureUnitKey) {
                switch SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)! {
                case .Kelvin: temperatureCell.tempratureLabel.text = String(format:"%gK", dayForecast.tempratue)
                case .Fahrenheit: temperatureCell.tempratureLabel.text = String(format:"%.1f℉", self.tempratureConverter.convertTemperatures( dayForecast.tempratue,  source:"Kelvin", target:"Fahrenheit"))
                case .Celsius: fallthrough
                default: temperatureCell.tempratureLabel.text = String(format:"%.0f°", self.tempratureConverter.convertTemperatures(dayForecast.tempratue,  source:"Kelvin", target:"Celsius"))
                }
            } else {
                temperatureCell.tempratureLabel.text = String(format:"%.0f°", self.tempratureConverter.convertTemperatures(dayForecast.tempratue,  source:"Kelvin", target:"Celsius"))
            }
            
            // set image when description contain key word
            let lowercaseDescription = dayForecast.description.lowercaseString
            if lowercaseDescription.rangeOfString("cloud") != nil {
                temperatureCell.weatherImageView.image = UIImage(named: "Cloudy_Big")
            } else if lowercaseDescription.rangeOfString("light") != nil {
                temperatureCell.weatherImageView.image = UIImage(named: "Lightning_Big")
            } else if lowercaseDescription.rangeOfString("wind") != nil {
                temperatureCell.weatherImageView.image = UIImage(named: "WInd_Big")
            } else {
                temperatureCell.weatherImageView.image = UIImage(named: "Sun_Big")
            }
            
            temperatureCell.weatherDescriptionLabel.text = dayForecast.description.firstCharacterUpperCase()
            
            temperatureCell.titleLabel.text = dayNameFromToday(indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92.0
    }
    
    // MAKR: Help methods
    
    func locationUpdated(notification: NSNotification) {
        var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
        openWeatherAPIManager.asynchronlyGetForecast(6, longitude: longitude!, latitude: latitude!, loadedForecasts: { (forecasts) -> () in
            self.forecasts = forecasts
        })
    }
    
    private func dayNameFromToday(daysFromToday: Int) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = NSDate()
        return dateFormatter.stringFromDate(today.dateByAddingTimeInterval(NSTimeInterval(60*60*24*daysFromToday)))
    }
    
    // MARK: Gestures
    @IBAction func swipeGesture(sender: UISwipeGestureRecognizer) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.Left: tabBarController.selectedIndex = 2
                case UISwipeGestureRecognizerDirection.Right: tabBarController.selectedIndex = 0
                default: break
                }
            }
        }
    }
}
