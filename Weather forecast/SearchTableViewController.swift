//
//  SearchTableViewController.swift
//  
//
//  Created by Jan Timar on 6.5.2015.
//
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    // FIXME: not finished yet
    
    // MARK: Properties 
    @IBOutlet weak var refresher: UIRefreshControl!
    
    private var cities: [OpenWeatheAPIManager.FoundCity] = [] {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.reloadData()
                self.refresher?.endRefreshing()
            })
        }
    }
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    private var searchBar :UISearchBar! {
        didSet {
            searchBar.placeholder = "City name"
            
//            searchBar.layer.borderColor = UIColor(red: 37.0/255.0, green: 142.0/255.0, blue: 1.0, alpha: 1.0).CGColor
//            searchBar.layer.borderWidth = 1.0
//            searchBar.layer.cornerRadius = 5.0
            
            searchBar.setBackgroundImage(UIImage(named: "Input"), forBarPosition: .Any, barMetrics: .Default)

            //searchBar.tintColor = UIColor(red: 37.0/255.0, green: 142.0/255.0, blue: 1.0, alpha: 1.0)
            searchBar.delegate = self
            searchBar.setImage(UIImage(named: "Search"), forSearchBarIcon: .Search, state: .Normal)
            searchBar.setImage(UIImage(named: "Close"), forSearchBarIcon: .Clear, state: .Normal)
            
            // set text color
            if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
                textFieldInsideSearchBar.textColor = UIColor(red: 37.0/255.0, green: 142.0/255.0, blue: 1.0, alpha: 1.0)
                
                println("Nastavit font search baru a zmenit jeho velkost")
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar()
        navigationItem.titleView = searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.FoundCityCellIdentifire, forIndexPath: indexPath) as! UITableViewCell

        if let foundCityCell = cell as? FoundCityTableViewCell {
                foundCityCell.country.text = cities[indexPath.row].counrty
                foundCityCell.city.text = "\(cities[indexPath.row].name),"
        }
        
        return cell
    }
    

    @IBAction func refresh(sender: UIRefreshControl) {
        openWeatherAPIManager.asynchronlySearchCityLike(named: searchBar.text,foundCities: foundedCity)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let foundCity = cities[indexPath.row]
        // save only if city is not in database
        if City.MR_findFirstWithPredicate(NSPredicate(format: "name LIKE %@ AND countryCode LIKE %@", argumentArray: [foundCity.name,foundCity.counrty])) == nil {
            var city = City.MR_createEntity() as! City
            city.name = foundCity.name
            city.latitude = foundCity.latitude
            city.longitude = foundCity.longitude
            city.countryCode = foundCity.counrty
            
            var saveError: NSError?    // check if parsed data is dictionary
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({ (succes, saveError) -> Void in
                if saveError == nil {
                    self.defaults.setBool(true, forKey: Constants.UsingSpecificPositionKey)
                    self.defaults.setDouble(city.latitude.doubleValue, forKey: Constants.LatitudeKey)
                    self.defaults.setDouble(city.longitude.doubleValue, forKey: Constants.LongitudeKey)
                    self.dismissViewControllerAnimated(true, completion:nil)
                }
            })
        }
    }
    

    // MARK: Search bar delgate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.refresher?.beginRefreshing()
        })
        openWeatherAPIManager.asynchronlySearchCityLike(named: searchText,foundCities: foundedCity)
    }
    
    func foundedCity(name: String,foundCities : [OpenWeatheAPIManager.FoundCity]) {
        // check if is actual searching result
        if searchBar?.text == name {
            cities = foundCities
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: Buttons press
    @IBAction func closeButtonPress(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
}
