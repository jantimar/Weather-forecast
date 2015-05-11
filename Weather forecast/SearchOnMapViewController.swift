//
//  SearchOnMapViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 11.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import MapKit

class SearchOnMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cityCoundSlider: UISlider!
    
    private lazy var openWeatherAPIManager: OpenWeatheAPIManager = {        // lazy initialization
        let lazilyOpenWeatherAPIManager = OpenWeatheAPIManager()
        return lazilyOpenWeatherAPIManager
        }()
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.showsUserLocation = true
        
        var region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        mapView.setRegion(region, animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateAnnotationFromCurrentMapPosition()
    }
    
    // MARK: Slide bar methods 
    
    @IBAction func sliderDidChangeValue(sender: UISlider) {
        updateAnnotationFromCurrentMapPosition()
    }
    
    // MARK: MAP delegates methods
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        updateAnnotationFromCurrentMapPosition()
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // is user annotationView
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annoationView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.FoundCityMapAnnotationIdentifire)
        if annoationView == nil {
            annoationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.FoundCityMapAnnotationIdentifire)
        }
        if let cityAnnotationView = annotation as? OpenWeatheAPIManager.FoundCityAnnotaion {
            annoationView.canShowCallout = true
            
            annoationView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            annoationView.image = UIImage(CGImage: UIImage.weatherImage(cityAnnotationView.subtitle)?.CGImage, scale: 3.5, orientation: .Up)
        }
        
        return annoationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            
            if let cityAnnotationView = view.annotation as? OpenWeatheAPIManager.FoundCityAnnotaion {
            if City.MR_findFirstWithPredicate(NSPredicate(format: "name LIKE %@ AND countryCode LIKE %@", argumentArray: [cityAnnotationView.title,cityAnnotationView.country])) == nil {
                
                var city = City.MR_createEntity() as! City
                city.name = cityAnnotationView.title
                city.latitude = cityAnnotationView.coordinate.latitude
                city.longitude = cityAnnotationView.coordinate.longitude
                city.countryCode = cityAnnotationView.country
                
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
    }
    
    func updateAnnotationFromCurrentMapPosition() {
        openWeatherAPIManager.asynchronlyFoundNearstCitiesForCoordinate(mapView.centerCoordinate.longitude, latitude: mapView.centerCoordinate.latitude, count: Int(cityCoundSlider.value)) { (latitude, longitude, foundedCities) -> () in
            if latitude == self.mapView.centerCoordinate.latitude && longitude == self.mapView.centerCoordinate.longitude {
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotations(foundedCities)
                })
            }
        }
    }
    
    
    // MARK: Buttons press
    @IBAction func closeButtonPress(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func segmentControlValueDidChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1: mapView.mapType = .Satellite
        case 2: mapView.mapType = .Hybrid
        case 0: fallthrough
        default: mapView.mapType = .Standard
        }
        
        // solved bug with pins image
        let annotations = mapView.annotations
        self.mapView.removeAnnotations(annotations)
        self.mapView.addAnnotations(annotations)
    }
}
