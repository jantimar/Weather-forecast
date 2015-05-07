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
    }
    
    struct WeatherState {
        var city: String
        var counrty: String
        var description: String
        var temprature: Float
        var humidity: Float
        var pressure: Float
        var windSpeed: Float
        var windDeggree: Float
        var rain: Float
        var clouds: Float
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/find?q=York&type=like
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/find", parameters: ["q": name, "type": "like"])
                .response { (request, response, data, error) in
                    
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
                                                    suitableCities.append(FoundCity(name: cityName, counrty: country))
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/forecast/daily?lat=35&lon=139&cnt=6&mode=json
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/forecast/daily", parameters: ["lat": latitude, "lon": longitude, "cnt": forDaysForecast, "mode": "json"])
                .response { (request, response, data, error) in
                    
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            //api.openweathermap.org/data/2.5/weather?lat=35&lon=139
            Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: ["lat": latitude, "lon": longitude])
                .response { (request, response, data, error) in
                    
                    if let responseData = data as? NSData {
                        var parseError: NSError?    // check if parsed data is dictionary
                        if let parsedJsonInDictionary = NSJSONSerialization.JSONObjectWithData(responseData,
                            options: NSJSONReadingOptions.AllowFragments,
                            error:&parseError) as? [String: AnyObject] {
                                
                                var weatherState = WeatherState(city: "", counrty: "", description: "", temprature: 0.0, humidity: 0.0, pressure: 0.0, windSpeed: 0.0, windDeggree: 0.0, rain: 0.0, clouds: 0.0)
                                
                                
                                if let cityName = parsedJsonInDictionary["name"] as? String {
                                    weatherState.city = cityName
                                }
                                if let countrySys = parsedJsonInDictionary["sys"] as? [String:AnyObject]  {
                                    if let country = countrySys["country"] as? String {
                                        weatherState.counrty = country
                                    }
                                }
                                if let wind = parsedJsonInDictionary["wind"] as? [String:Float] {
                                    if let windSpeed = wind["speed"] {
                                        weatherState.windSpeed = windSpeed
                                    }
                                    if let windDegrees = wind["deg"] {
                                        weatherState.windDeggree = windDegrees
                                    }
                                }
                                if let main = parsedJsonInDictionary["main"] as? [String:Float] {
                                    if let temprature = main["temp"] {
                                        weatherState.temprature = temprature
                                        if let pressure = main["pressure"] {
                                            weatherState.pressure = pressure
                                        }
                                        if let humidity = main["humidity"] {
                                            weatherState.humidity = humidity
                                        }
                                    }
                                }
                                
                                if let weather = parsedJsonInDictionary["weather"] as? [AnyObject]{
                                    if let firstWeather = weather.first as? [String:AnyObject] {
                                        if let description = firstWeather["description"] as? String {
                                            weatherState.description = description
                                        }
                                    }
                                }
                                if let clouds = parsedJsonInDictionary["clouds"] as? [String:Float] {
                                    if let cloudsAll = clouds["all"] {
                                        weatherState.clouds = cloudsAll
                                    }
                                }
                                if let rain = parsedJsonInDictionary["rain"] as? [String:Float]{
                                    if let last3Hours = rain["3h"] {
                                        weatherState.rain = last3Hours
                                    }
                                }
                                
                                loadedWeather(weatherState)
                        }
                    }
            }
        }
    }
}

