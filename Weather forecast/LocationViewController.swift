//
//  LocationViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 8.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

import MGSwipeTableCell

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var cities = [City]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private var tempratureConverter = TempratureConverter()

    private let rowHeight: CGFloat = 92.0
    
    // MARK: Life cycle methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load city from databas
        if let findedCities = City.MR_findAll() as? [City] {
            cities = findedCities
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: Constants.UserCoordinateKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.UserCoordinateKey, object: nil)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TempretureCelldentifire, forIndexPath: indexPath) as! UITableViewCell
        
        if let temperatureCell = cell as? TempretureTableViewCell {
            
            
            switch indexPath.section {
            case 0:
                temperatureCell.currentImageView.alpha = 1.0
                
                var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
                updateTempretureCellUI(temperatureCell, latitude: latitude!, longitude: longitude!, rowIdentifire: indexPath.row)
                
                temperatureCell.rightButtons = []
            case 1:
                let city = cities[indexPath.row]
                temperatureCell.currentImageView.alpha = 0.0
                updateTempretureCellUI(temperatureCell, latitude: city.latitude.doubleValue, longitude: city.longitude.doubleValue, rowIdentifire: indexPath.row + indexPath.section)
                
                    
                var deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "DeleteIcon"), backgroundColor: UIColor(patternImage: UIImage(named: "Delete")!), callback: { (deletedCell) -> Bool in
                    
                    let city = self.cities[indexPath.row]
                    self.cities.removeAtIndex(indexPath.row)
                    
                    // remove on background
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        city.MR_deleteEntity()
                        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                    })
                    return true
                    })
                // height of cell for square button
                deleteButton.frame = CGRectMake(0.0, 0.0, rowHeight, rowHeight)
                temperatureCell.rightButtons = [deleteButton]
            default: break
            }
        }
        
        return cell
    }
    
    private func updateTempretureCellUI(cell: TempretureTableViewCell, latitude: Double, longitude: Double,rowIdentifire: Int) {
        cell.tag = rowIdentifire
        openWeatherAPIManager.asynchronlyGetWeatherForCoordinate(longitude, latitude: latitude, loadedWeather: { (weatherState) -> () in
            if cell.tag == rowIdentifire && weatherState.temprature != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.titleLabel.setTextWithAnimation("\(weatherState.city)")
                    
                    // set temprature in format
                    if weatherState.temprature != nil {
                    if let tempratureTypeRawValue = self.defaults.stringForKey(Constants.TempratureUnitKey) {
                        cell.tempratureLabel.setTextWithAnimation(String(format:"%@", weatherState.temprature!.tempratureInFormatFromKelvin(SettignsTableViewController.TempratureType(rawValue: tempratureTypeRawValue)!)))
                    } else {
                        cell.tempratureLabel.setTextWithAnimation(String(format:"%@", weatherState.temprature!.tempratureInFormatFromKelvin(.Celsius)))
                    }
                    } else {
                        cell.tempratureLabel.setTextWithAnimation("-")
                    }
                    
                    // set image when description contain key word
                    cell.weatherImageView.setImageWithAnimation(UIImage.weatherImage(weatherState.description))
                    
                    cell.weatherDescriptionLabel.setTextWithAnimation(weatherState.description.firstCharacterUpperCase())
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
        case 0:
            var (latitude,longitude) = WeatherLocationManager.sharedInstance.userPosition()
            return latitude != nil && longitude != nil ? 1 : 0
        case 1: return cities.count
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defaults.setBool(indexPath.section == 1, forKey: Constants.UsingSpecificPositionKey)
        switch indexPath.section {
        case 0:
            self.dismissViewControllerAnimated(true, completion: nil)
        case 1:
            let city = cities[indexPath.row]
            
            defaults.setBool(true, forKey: Constants.UsingSpecificPositionKey)
            defaults.setDouble(city.latitude.doubleValue, forKey: Constants.LatitudeKey)
            defaults.setDouble(city.longitude.doubleValue, forKey: Constants.LongitudeKey)
            dismissViewControllerAnimated(true, completion:nil)
        default: break
        }
    }
    
    
    // MARK: Locations delegate
    
    func locationUpdated(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    // MARK: Buttons press
    
    @IBAction func doneButtonPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

}
