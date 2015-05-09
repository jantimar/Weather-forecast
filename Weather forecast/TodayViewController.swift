//
//  TodayViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 7.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: properties
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cityStateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var currentImageView: UIImageView!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var weatherStateView: ActualWeatherStateView!
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private var tempratureConverter = TempratureConverter()
    
    
    // MARK: Life cycle methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let useSpecificPositionForWeather = defaults.boolForKey(Constants.UsingSpecificPositionKey)

        if useSpecificPositionForWeather
        {
            currentImageView?.alpha = 0.0   // load weather state from saved coordinate
            
            let latitude = defaults.doubleForKey(Constants.LatitudeKey)
            let longitude = defaults.doubleForKey(Constants.LongitudeKey)
            
            loadingActivityIndicator?.startAnimating()
            openWeatherAPIManager.asynchronlyGetWeatherForCoordinate( longitude, latitude: latitude, loadedWeather: updateUI)
            
        } else {
            currentImageView?.alpha = 1.0
            
            var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
            if latitude != nil && longitude != nil {
                openWeatherAPIManager.asynchronlyGetWeatherForCoordinate( longitude!, latitude: latitude!, loadedWeather: updateUI)
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
    
    func locationUpdated(notification: NSNotification) {
        var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
        openWeatherAPIManager.asynchronlyGetWeatherForCoordinate( longitude!, latitude: latitude!, loadedWeather: updateUI)
    }
    
    private func updateUI(weatherState: OpenWeatheAPIManager.WeatherState) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cityStateLabel.setTextWithAnimation("\(weatherState.city), \(weatherState.counrty)")
            
            if weatherState.temprature != nil {
                if let tempratureTypeRawValue = self.defaults.stringForKey(Constants.TempratureUnitKey) {
                    self.descriptionLabel.setTextWithAnimation(String(format:"%@%@ | %@", weatherState.temprature!.tempratureInFormatFromKelvin(SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)!),SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)!.unitSymbol(), weatherState.description))
                } else {
                    self.descriptionLabel.setTextWithAnimation(String(format:"%@%@ | %@", weatherState.temprature!.tempratureInFormatFromKelvin(.Celsius),SettignsTableViewController.TempratureType.Celsius.unitSymbol(), weatherState.description))
                }
            } else {
                self.descriptionLabel.setTextWithAnimation(weatherState.description)
            }
            
            self.weatherIconImageView.setImageWithAnimation(UIImage.weatherImage(weatherState.description))
            
            self.weatherStateView.updateWeathes(weatherState)
            
            self.loadingActivityIndicator?.stopAnimating()
        })
    }
    
    // MARK: Buttons press
    
    @IBAction func shareButtonPress(sender: AnyObject) {
        if descriptionLabel.text != nil && cityStateLabel.text != nil {
            let textToShare = "Weather forecast \(descriptionLabel.text!) in \(cityStateLabel.text!)"
            
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
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
