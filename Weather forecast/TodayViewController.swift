//
//  TodayViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 7.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: properties
    
    @IBOutlet weak var currentImageView: UIImageView!
    
    @IBOutlet weak var cityStateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var cloudsAllLabel: UILabel!
    
    @IBOutlet weak var rainLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var windDirectionLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private lazy var locationManager:CLLocationManager = {        // lazy initialization for location
        let lazilyLocationManager = CLLocationManager()
        lazilyLocationManager.delegate = self
        lazilyLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        lazilyLocationManager.requestAlwaysAuthorization()
        lazilyLocationManager.distanceFilter = 100 // update location after 100 m
        return lazilyLocationManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private var tempratureConverter = TempratureConverter()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let useCurrentPositionForWeather = defaults.boolForKey(Constants.UsingUserPositionKey)

        if useCurrentPositionForWeather
        {
            currentImageView?.alpha = 0.0   // load weather state from saved coordinate
            
        } else {
            currentImageView?.alpha = 1.0
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
            openWeatherAPIManager.asynchronlyGetWeatherForCoordinate( location.coordinate.longitude, latitude: location.coordinate.latitude, loadedWeather: updateUI)
        }
    }
    
    
    private func updateUI(weatherState: OpenWeatheAPIManager.WeatherState) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cityStateLabel.text = "\(weatherState.city), \(weatherState.counrty)"
            
            
            
            if weatherState.temprature != nil {
                if let tempratureTypeRawValue = self.defaults.stringForKey(Constants.TempratureUnitKey) {
                    switch SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)! {
                    case .Kelvin: self.descriptionLabel.text = String(format:"%.1fK | %@", weatherState.temprature!,weatherState.description)
                    case .Fahrenheit: self.descriptionLabel.text = String(format:"%.1f℉ | %@", self.tempratureConverter.convertTemperatures(weatherState.temprature!,  source:"Kelvin", target:"Fahrenheit"),weatherState.description)
                    case .Celsius: fallthrough
                    default: self.descriptionLabel.text = String(format:"%.1f℃ | %@", self.tempratureConverter.convertTemperatures(weatherState.temprature!,  source:"Kelvin", target:"Celsius"),weatherState.description)
                    }
                } else {
                    self.descriptionLabel.text = String(format:"%.1f℃ | %@", self.tempratureConverter.convertTemperatures(weatherState.temprature!,  source:"Kelvin", target:"Celsius"),weatherState.description)
                }
            } else {
                self.descriptionLabel.text = weatherState.description
            }
            
            self.cloudsAllLabel.text = weatherState.clouds != nil ? String(format:"%g%%",weatherState.clouds!) : "-"
            
            self.rainLabel.text =  weatherState.rain != nil ? String(format:"%g mm",weatherState.rain!) : "-"
            
            //0.621371192 - kph to - mph contant
            if weatherState.windSpeed != nil {
                if let lengthTypeRawValue = self.defaults.stringForKey(Constants.LengthUnitKey) {
                    switch SettignsTableViewController.LengthType(rawValue: lengthTypeRawValue)! {
                    case .Miles: self.windSpeedLabel.text = String(format:"%.1f mph",weatherState.windSpeed!/0.621371192)
                    case .Meters: fallthrough
                    default: self.windSpeedLabel.text = String(format:"%g km/h",weatherState.windSpeed!)
                    }
                } else {
                    self.windSpeedLabel.text = String(format:"%g km/h",weatherState.windSpeed!)
                }
            } else {
                self.windSpeedLabel.text = "-"
            }
            
            self.pressureLabel.text = weatherState.pressure != nil ? String(format:"%g hPa",weatherState.pressure!) : "-"
            
            let lowercaseDescription = weatherState.description.lowercaseString
            if lowercaseDescription.rangeOfString("cloud") != nil {
                self.weatherIcon.image = UIImage(named: "Cloudy_Big")
            } else if lowercaseDescription.rangeOfString("light") != nil {
                self.weatherIcon.image = UIImage(named: "Lightning_Big")
            } else if lowercaseDescription.rangeOfString("wind") != nil {
                self.weatherIcon.image = UIImage(named: "WInd_Big")
            } else {
                self.weatherIcon.image = UIImage(named: "Sun_Big")
            }
            
            // wind direction
            if weatherState.windDeggree > 348.75 || weatherState.windDeggree <= 11.25 {
                self.windDirectionLabel.text = "N"
            } else if weatherState.windDeggree > 11.2 && weatherState.windDeggree <= 33.75 {
                self.windDirectionLabel.text = "NNE"
            } else if weatherState.windDeggree > 33.75 && weatherState.windDeggree <= 56.25 {
                self.windDirectionLabel.text = "NE"
            } else if weatherState.windDeggree > 56.25 && weatherState.windDeggree <= 78.75 {
                self.windDirectionLabel.text = "ENE"
            } else if weatherState.windDeggree > 78.75 && weatherState.windDeggree <= 101.25 {
                self.windDirectionLabel.text = "E"
            } else if weatherState.windDeggree > 101.25 && weatherState.windDeggree <= 123.75 {
                self.windDirectionLabel.text = "ESE"
            } else if weatherState.windDeggree > 123.75 && weatherState.windDeggree <= 146.25 {
                self.windDirectionLabel.text = "SE"
            } else if weatherState.windDeggree > 146.25 && weatherState.windDeggree <= 168.75 {
                self.windDirectionLabel.text = "SSE"
            } else if weatherState.windDeggree > 168.75 && weatherState.windDeggree <= 191.25 {
                self.windDirectionLabel.text = "S"
            } else if weatherState.windDeggree > 191.25 && weatherState.windDeggree <= 213.75 {
                self.windDirectionLabel.text = "SSW"
            } else if weatherState.windDeggree > 213.75 && weatherState.windDeggree <= 236.25 {
                self.windDirectionLabel.text = "SW"
            } else if weatherState.windDeggree > 236.25 && weatherState.windDeggree <= 258.75 {
                self.windDirectionLabel.text = "WSW"
            } else if weatherState.windDeggree > 258.75 && weatherState.windDeggree <= 281.25 {
                self.windDirectionLabel.text = "W"
            } else if weatherState.windDeggree > 281.25 && weatherState.windDeggree <= 303.75 {
                self.windDirectionLabel.text = "WNW"
            } else if weatherState.windDeggree > 303.75 && weatherState.windDeggree <= 326.25 {
                self.windDirectionLabel.text = "NW"
            } else if weatherState.windDeggree > 326.25 && weatherState.windDeggree <= 348.75 {
                self.windDirectionLabel.text = "NNW"
            }
            
        })
    }
    
    // MARK: Buttons press
    
    @IBAction func shareButtonPress(sender: AnyObject) {
        let textToShare = "Weather forecast \(descriptionLabel.text!) in \(cityStateLabel.text!)"
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    // MARK: Gestures
    
    @IBAction func swipeGesture(sender: UISwipeGestureRecognizer) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.Left: tabBarController.selectedIndex = 1
                case UISwipeGestureRecognizerDirection.Right: tabBarController.selectedIndex = 2
                default: break
                }
            }
        }
    }

}
