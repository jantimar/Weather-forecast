//
//  LocationViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 8.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import CoreLocation

import MGSwipeTableCell

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private lazy var locationManager:CLLocationManager = {        // lazy initialization for location
        let lazilyLocationManager = CLLocationManager()
        lazilyLocationManager.delegate = self
        lazilyLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        lazilyLocationManager.requestAlwaysAuthorization()
        return lazilyLocationManager
        }()
    
    private var cities = [City]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private var tempratureConverter = TempratureConverter()

    private var userPosition : CLLocation?
    
    private let rowHeight: CGFloat = 92.0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load city from databas
        if let findedCities = City.MR_findAll() as? [City] {
            cities = findedCities
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TempretureCelldentifire, forIndexPath: indexPath) as! UITableViewCell
        
        if let temperatureCell = cell as? TempretureTableViewCell {
            
            
            switch indexPath.section {
            case 0:
                temperatureCell.tag = indexPath.row
                
                updateTempretureCellUI(temperatureCell, latitude: userPosition!.coordinate.latitude, longitude: userPosition!.coordinate.longitude, row: indexPath.row)
                
                temperatureCell.rightButtons = []
            case 1:
                let city = cities[indexPath.row]
                updateTempretureCellUI(temperatureCell, latitude: city.latitude.doubleValue, longitude: city.longitude.doubleValue, row: indexPath.row)
                
                    
                var button = MGSwipeButton(title: "", icon: UIImage(named: "DeleteIcon"), backgroundColor: UIColor(patternImage: UIImage(named: "Delete")!), callback: { (deletedCell) -> Bool in
                    
                    let city = self.cities[deletedCell.tag]
                    self.cities.removeAtIndex(deletedCell.tag)
                    println("TAAAG \(deletedCell.tag) ROOWW \(indexPath.row)")
                    // remove on background
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        city.MR_deleteEntity()
                        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                    })
                    return true
                    })
                // height of cell for square button
                button.frame = CGRectMake(0.0, 0.0, rowHeight, rowHeight)
                temperatureCell.rightButtons = [button]
            default: break
            }
        }
        
        return cell
    }
    
    private func updateTempretureCellUI(cell: TempretureTableViewCell, latitude: Double, longitude: Double,row: Int) {
        cell.tag = row
        openWeatherAPIManager.asynchronlyGetWeatherForCoordinate(longitude, latitude: latitude, loadedWeather: { (weatherState) -> () in
            if cell.tag == row && weatherState.temprature != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.titleLabel.text = "\(weatherState.city)"
                    
                    // set temprature in format
                    if let tempratureTypeRawValue = self.defaults.stringForKey(Constants.TempratureUnitKey) {
                        switch SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)! {
                        case .Kelvin: cell.tempratureLabel.text = String(format:"%gK", weatherState.temprature!)
                        case .Fahrenheit: cell.tempratureLabel.text = String(format:"%.1f℉", self.tempratureConverter.convertTemperatures( weatherState.temprature!,  source:"Kelvin", target:"Fahrenheit"))
                        case .Celsius: fallthrough
                        default: cell.tempratureLabel.text = String(format:"%.0f°", self.tempratureConverter.convertTemperatures(weatherState.temprature!,  source:"Kelvin", target:"Celsius"))
                        }
                    } else {
                        cell.tempratureLabel.text = String(format:"%.0f°", self.tempratureConverter.convertTemperatures(weatherState.temprature!,  source:"Kelvin", target:"Celsius"))
                    }
                    
                    // set image when description contain key word
                    let lowercaseDescription = weatherState.description.lowercaseString
                    if lowercaseDescription.rangeOfString("cloud") != nil {
                        cell.weatherImageView.image = UIImage(named: "Cloudy_Big")
                    } else if lowercaseDescription.rangeOfString("light") != nil {
                        cell.weatherImageView.image = UIImage(named: "Lightning_Big")
                    } else if lowercaseDescription.rangeOfString("wind") != nil {
                        cell.weatherImageView.image = UIImage(named: "WInd_Big")
                    } else {
                        cell.weatherImageView.image = UIImage(named: "Sun_Big")
                    }
                    
                    cell.weatherDescriptionLabel.text = weatherState.description
                })
            }
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return userPosition != nil ? 1 : 0
        case 1: return cities.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    
    // MARK: Locations delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            userPosition = location
            tableView?.reloadData()
            locationManager.stopUpdatingLocation()  // load only first location
        }
    }
    
    // MARK: Buttons press
    
    @IBAction func doneButtonPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

}
