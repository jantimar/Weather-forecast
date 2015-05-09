//
//  OpenWeatheAPIManager.swift
//  Weather forecast
//
//  Created by Jan Timar on 6.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

import Alamofire

class OpenWeatheAPIManager: NSObject {
    
    struct FoundCity {
        var name: String
        var counrty: String
        var latitude: Double
        var longitude: Double
    }
    
    struct WeatherState {
        var city: String
        var counrty: String
        var description: String
        var temprature: Float?
        var humidity: Float?
        var pressure: Float?
        var windSpeed: Float?
        var windDeggree: Float?
        var rain: Float?
        var clouds: Float?
        
        init() {
            city = ""
            counrty = ""
            description = ""
        }
    }
    
    struct Forecasts {
        var city: String
        var latitude: Double
        var longitude: Double
        var forecast: [Forecast]
        
        init() {
            city = ""
            latitude = 0.0
            longitude = 0.0
            forecast = [Forecast]()
        }
    }
    
    struct Forecast {
        var tempratue: Float
        var description: String
    }
    
    
    func asynchronlySearchCityLike(named name: String, foundCities: (name: String, [FoundCity]) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/find?q=York&type=like
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/find", parameters: ["q": name, "type": "like"])
                .response { (request, response, data, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let responseData = data as? NSData {
                        var parseError: NSError?    // check if parsed data is dictionary
                        if let parsedJsonInDictionary = NSJSONSerialization.JSONObjectWithData(responseData,
                            options: NSJSONReadingOptions.AllowFragments,
                            error:&parseError) as? [String: AnyObject] {
                                
                                if let cityList = parsedJsonInDictionary["list"] as? [AnyObject] {
                                    
                                    var suitableCities = [FoundCity]()
                                    
                                    
                                    for city in cityList as! [[String:AnyObject]] {
                                        if let citySys = city["sys"] as? [String:String] {
                                            if let cityName = city["name"] as? String {
                                                if let country = citySys["country"] {
                                                    if let coordination = city["coord"] as? [String:Double] {
                                                        if let latitude = coordination["lat"] {
                                                            if let longitude = coordination["lon"]{
                                                                suitableCities.append(FoundCity(name: cityName, counrty: country, latitude: latitude, longitude: longitude))
                                                        }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    foundCities(name: name, suitableCities)
                                }
                        }
                    }
            }
        }
    }
    
    func asynchronlyGetForecast(forDaysForecast: Int, longitude: Double, latitude: Double, loadedForecasts:(Forecasts) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/forecast/daily?lat=35&lon=139&cnt=6&mode=json
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: ["lat": latitude, "lon": longitude, "cnt": forDaysForecast, "mode": "json"])
                .response { (request, response, data, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let responseData = data as? NSData {
                        var parseError: NSError?    // check if parsed data is dictionary
                        if let parsedJsonInDictionary = NSJSONSerialization.JSONObjectWithData(responseData,
                            options: NSJSONReadingOptions.AllowFragments,
                            error:&parseError) as? [String: AnyObject] {
                                
                                var forecasts = Forecasts()
                                forecasts.latitude = latitude
                                forecasts.longitude = longitude
                                
                                if let city = parsedJsonInDictionary["city"] as? [String:AnyObject] {
                                    if let cityName = city["name"] as? String {
                                        forecasts.city = cityName
                                    }
                                }
                                
                                if let list = parsedJsonInDictionary["list"] as? [[String:AnyObject]]{
                                    for dayForecast in list {
                                        if let temprature = dayForecast["temp"] as? [String:Float] {
                                            if let dayTeplature = temprature["day"] {
                                                if let weathers = dayForecast["weather"] as? [AnyObject] {
                                                    if let firstWeather = weathers.first as? [String:AnyObject] {
                                                        if let description = firstWeather["description"] as? String {
                                                            forecasts.forecast.append(Forecast(tempratue: dayTeplature, description: description))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                loadedForecasts(forecasts)
                        }
                    }
            }
        }
    }
    
    
    
    func asynchronlyGetWeatherForCoordinate(longitude: Double,latitude: Double,loadedWeather: (WeatherState) -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/weather?lat=35&lon=139
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: ["lat": latitude, "lon": longitude])
                .response { (request, response, data, error) in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if let responseData = data as? NSData {
                        var parseError: NSError?    // check if parsed data is dictionary
                        if let parsedJsonInDictionary = NSJSONSerialization.JSONObjectWithData(responseData,
                            options: NSJSONReadingOptions.AllowFragments,
                            error:&parseError) as? [String: AnyObject] {
                                
                                var weatherState = WeatherState()
                                
                                
                                if let cityName = parsedJsonInDictionary["name"] as? String {
                                    weatherState.city = cityName
                                }
                                if let countrySys = parsedJsonInDictionary["sys"] as? [String:AnyObject]  {
                                    if let country = countrySys["country"] as? String {
                                        weatherState.counrty = country
                                    }
                                }
                                if let wind = parsedJsonInDictionary["wind"] as? [String:Float] {
                                    weatherState.windSpeed = wind["speed"]
                                    weatherState.windDeggree = wind["deg"]
                                }
                                if let main = parsedJsonInDictionary["main"] as? [String:Float] {
                                    weatherState.temprature = main["temp"]
                                    weatherState.pressure = main["pressure"]
                                    weatherState.humidity = main["humidity"]
                                }
                                
                                if let weather = parsedJsonInDictionary["weather"] as? [AnyObject]{
                                    if let firstWeather = weather.first as? [String:AnyObject] {
                                        if let description = firstWeather["description"] as? String {
                                            weatherState.description = description
                                        }
                                    }
                                }
                                if let clouds = parsedJsonInDictionary["clouds"] as? [String:Float] {
                                    weatherState.clouds = clouds["all"]                                }
                                if let rain = parsedJsonInDictionary["rain"] as? [String:Float]{
                                    weatherState.rain = rain["3h"]
                                }
                                
                                loadedWeather(weatherState)
                        }
                    }
            }
        }
    }
}

