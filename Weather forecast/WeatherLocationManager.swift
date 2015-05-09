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
   
     var userLocation: CLLocation?
    
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
    
    // pozriet singelton
//    static var weatherLocationManage: WeatherLocationManager! {
//        get {
//            if weatherLocationManage == nil {
//                WeatherLocationManager = WeatherLocationManager()
//            }
//            return WeatherLocationManager
//        }
//    }
//    
//    private override init() {
//        super.init()
//        locationManager.startUpdatingLocation()
//    }
//    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            userLocation = location
        }
    }
    
}
