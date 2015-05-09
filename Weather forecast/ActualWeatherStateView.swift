//
//  ActualWeatherStateView.swift
//  Weather forecast
//
//  Created by Jan Timar on 8.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

class ActualWeatherStateView: UIView {
    
    
    @IBOutlet weak var cloudsAllLabel: UILabel!
    
    @IBOutlet weak var rainLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var windDirectionLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    
    private var defaults = NSUserDefaults.standardUserDefaults()

    func updateWeathes(weather: OpenWeatheAPIManager.WeatherState) {
        
        self.cloudsAllLabel.setTextWithAnimation(weather.clouds != nil ? String(format:"%g%%",weather.clouds!) : "-")
        
        self.rainLabel.setTextWithAnimation(weather.rain != nil ? String(format:"%g mm",weather.rain!) : "-")
        
        //0.621371192 - kph to - mph contant
        if weather.windSpeed != nil {
            if let lengthTypeRawValue = self.defaults.stringForKey(Constants.LengthUnitKey) {
                switch SettignsTableViewController.LengthType(rawValue: lengthTypeRawValue)! {
                case .Miles: self.windSpeedLabel.setTextWithAnimation(String(format:"%.1f mph",weather.windSpeed!/0.621371192))
                case .Meters: fallthrough
                default: self.windSpeedLabel.setTextWithAnimation(String(format:"%g km/h",weather.windSpeed!))
                }
            } else {
                self.windSpeedLabel.setTextWithAnimation(String(format:"%g km/h",weather.windSpeed!))
            }
        } else {
            self.windSpeedLabel.setTextWithAnimation("-")
        }
        
        self.pressureLabel.setTextWithAnimation(weather.pressure != nil ? String(format:"%g hPa",weather.pressure!) : "-")
        
        // wind direction
        if weather.windDeggree != nil {
            self.windDirectionLabel.setTextWithAnimation(weather.windDeggree!.direction())
        }
    }
}
