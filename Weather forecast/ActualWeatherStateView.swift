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
        
        self.cloudsAllLabel.text = weather.clouds != nil ? String(format:"%g%%",weather.clouds!) : "-"
        
        self.rainLabel.text =  weather.rain != nil ? String(format:"%g mm",weather.rain!) : "-"
        
        //0.621371192 - kph to - mph contant
        if weather.windSpeed != nil {
            if let lengthTypeRawValue = self.defaults.stringForKey(Constants.LengthUnitKey) {
                switch SettignsTableViewController.LengthType(rawValue: lengthTypeRawValue)! {
                case .Miles: self.windSpeedLabel.text = String(format:"%.1f mph",weather.windSpeed!/0.621371192)
                case .Meters: fallthrough
                default: self.windSpeedLabel.text = String(format:"%g km/h",weather.windSpeed!)
                }
            } else {
                self.windSpeedLabel.text = String(format:"%g km/h",weather.windSpeed!)
            }
        } else {
            self.windSpeedLabel.text = "-"
        }
        
        self.pressureLabel.text = weather.pressure != nil ? String(format:"%g hPa",weather.pressure!) : "-"
        
        // wind direction
        if weather.windDeggree > 348.75 || weather.windDeggree <= 11.25 {
            self.windDirectionLabel.text = "N"
        } else if weather.windDeggree > 11.2 && weather.windDeggree <= 33.75 {
            self.windDirectionLabel.text = "NNE"
        } else if weather.windDeggree > 33.75 && weather.windDeggree <= 56.25 {
            self.windDirectionLabel.text = "NE"
        } else if weather.windDeggree > 56.25 && weather.windDeggree <= 78.75 {
            self.windDirectionLabel.text = "ENE"
        } else if weather.windDeggree > 78.75 && weather.windDeggree <= 101.25 {
            self.windDirectionLabel.text = "E"
        } else if weather.windDeggree > 101.25 && weather.windDeggree <= 123.75 {
            self.windDirectionLabel.text = "ESE"
        } else if weather.windDeggree > 123.75 && weather.windDeggree <= 146.25 {
            self.windDirectionLabel.text = "SE"
        } else if weather.windDeggree > 146.25 && weather.windDeggree <= 168.75 {
            self.windDirectionLabel.text = "SSE"
        } else if weather.windDeggree > 168.75 && weather.windDeggree <= 191.25 {
            self.windDirectionLabel.text = "S"
        } else if weather.windDeggree > 191.25 && weather.windDeggree <= 213.75 {
            self.windDirectionLabel.text = "SSW"
        } else if weather.windDeggree > 213.75 && weather.windDeggree <= 236.25 {
            self.windDirectionLabel.text = "SW"
        } else if weather.windDeggree > 236.25 && weather.windDeggree <= 258.75 {
            self.windDirectionLabel.text = "WSW"
        } else if weather.windDeggree > 258.75 && weather.windDeggree <= 281.25 {
            self.windDirectionLabel.text = "W"
        } else if weather.windDeggree > 281.25 && weather.windDeggree <= 303.75 {
            self.windDirectionLabel.text = "WNW"
        } else if weather.windDeggree > 303.75 && weather.windDeggree <= 326.25 {
            self.windDirectionLabel.text = "NW"
        } else if weather.windDeggree > 326.25 && weather.windDeggree <= 348.75 {
            self.windDirectionLabel.text = "NNW"
        }

    }
}
