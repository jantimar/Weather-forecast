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
                self.navigationItem.title = self.forecasts.city
            })
        }
    }
    
    
    private var tempratureConverter = TempratureConverter()
    
    // MARK: Life cycle methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        forecasts.forecast = nil
        tableView.reloadData()
        
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
        return forecasts.forecast != nil ? forecasts.forecast!.count : 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TempretureCelldentifire, forIndexPath: indexPath) as! UITableViewCell
        
        if let temperatureCell = cell as? TempretureTableViewCell {
            let dayForecast = forecasts.forecast![indexPath.row]
            
            if dayForecast.error != nil {
                temperatureCell.tempratureLabel.setTextWithAnimation("")
                temperatureCell.titleLabel.text = dayNameFromToday(indexPath.row)
                temperatureCell.weatherDescriptionLabel.setTextWithAnimation(dayForecast.error!.description)
            } else {
                // set temprature in format
                if let tempratureTypeRawValue = defaults.stringForKey(Constants.TempratureUnitKey) {
                    temperatureCell.tempratureLabel.setTextWithAnimation(String(format:"%@°", dayForecast.tempratue.tempratureInFormatFromKelvin(SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)!)))
                } else {
                    temperatureCell.tempratureLabel.setTextWithAnimation(String(format:"%@°", dayForecast.tempratue.tempratureInFormatFromKelvin(.Celsius)))
                }
                
                // set image when description contain key word
                temperatureCell.weatherImageView.setImageWithAnimation(UIImage.weatherImage(dayForecast.description))
                
                temperatureCell.weatherDescriptionLabel.setTextWithAnimation(dayForecast.description.firstCharacterUpperCase())
                
                // dont animate is still same
                temperatureCell.titleLabel.text = dayNameFromToday(indexPath.row)
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92.0
    }
    
    // MAKR: Help methods
    
    func locationUpdated(notification: NSNotification) {
        var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
        if latitude != nil && longitude != nil {
            openWeatherAPIManager.asynchronlyGetForecast(6, longitude: longitude!, latitude: latitude!, loadedForecasts: { (forecasts) -> () in
            self.forecasts = forecasts
            })
        } else {
            var alertController = UIAlertController (title: "Error", message: "User position is denied", preferredStyle: .Alert)
            
            var settingsAction = UIAlertAction(title: "Open Settings", style: .Default) { (_) -> Void in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
            var cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil);
        }
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
