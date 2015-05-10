//
//  WeatherLocationManager.swift
//  Weather forecast
//
//  Created by Jan Timar on 8.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherLocationManager: NSObject, CLLocationManagerDelegate {
   
    
    // MARK: Properties
    
    private var userLocation: CLLocation?
    
    func userPosition() -> (Double?,Double?) {
        return userLocation != nil ? (userLocation!.coordinate.latitude,userLocation!.coordinate.longitude) : (nil,nil)
    }
    
    private lazy var locationManager:CLLocationManager = {        // lazy initialization for location
        let lazilyLocationManager = CLLocationManager()
        lazilyLocationManager.delegate = self
        lazilyLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        lazilyLocationManager.requestAlwaysAuthorization()
        return lazilyLocationManager
        }()
    
    // Singelton
    class var sharedInstance: WeatherLocationManager {
        struct Static {
            static var instance: WeatherLocationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = WeatherLocationManager()
            Static.instance?.locationManager.startUpdatingLocation()
        }
        
        return Static.instance!
    }
    
    // Mark: Location managar delegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied:
            // for stop waiting for position
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.UserCoordinateKey, object: nil, userInfo:nil)
            break
        default:
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            userLocation = location
            
            // stop uplouding location
            locationManager.stopUpdatingLocation()
            
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.UserCoordinateKey, object: nil, userInfo: [Constants.LongitudeKey:location.coordinate.longitude,Constants.LatitudeKey:location.coordinate.latitude])
        }
    }
    
}
