//
//  SettignsTableViewController.swift
//  Weather forecast
//
//  Created by Jan Timar on 6.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

class SettignsTableViewController: UITableViewController {
    
    
    // MARK: Properties
    enum TempratureType: String {
        case Kelvin = "Kelvin"
        case Celsius = "Celsius"
        case Fahrenheit = "Fahrenheit"
        
        func unitSymbol() -> String {
            switch self {
            case .Kelvin: return "K"
            case .Celsius: return "℃"
            case .Fahrenheit: return "℉"
            }
        }
    }
    
    enum LengthType: String {
        case Meters = "Meters"
        case Miles = "Miles"
    }
    
    private var lengthType: LengthType? {
        didSet {
            if lengthType != nil {
                lengthButton.setTextWithAnimation(lengthType!.rawValue)
                defaults.setObject(lengthType!.rawValue, forKey: Constants.LengthUnitKey)
            }
        }
    }
    
    private var tempratureType: TempratureType? {
        didSet {
            if tempratureType != nil {
                tempretureButton.setTextWithAnimation(tempratureType!.rawValue)
                defaults.setObject(tempratureType!.rawValue, forKey: Constants.TempratureUnitKey)
            }
        }
    }
    
    private var defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tempretureButton: UIButton!
    
    @IBOutlet weak var lengthButton: UIButton!
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
        // set header title color
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel.textColor = UIColor(red: 37.0/255.0, green: 142.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load value from user defaults
        if let lengthTypeRawValue = defaults.stringForKey(Constants.LengthUnitKey) {
            lengthType = LengthType(rawValue: lengthTypeRawValue)
        } else {
            lengthType = .Meters
        }
        
        if let tempratureTypeRawValue = defaults.stringForKey(Constants.TempratureUnitKey) {
            tempratureType = TempratureType(rawValue: tempratureTypeRawValue)
        } else {
            tempratureType = .Celsius
        }
        
        // set gestures
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeGesture:")
        swipeRight.direction = .Right
        self.tableView?.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeGesture:")
        swipeLeft.direction = .Left
        self.tableView?.addGestureRecognizer(swipeLeft)
    }
    
    // MARK: Buttons press
    
    @IBAction func lengthUnitPress(sender: UIButton) {
        if lengthType != nil {
            switch lengthType! {
            case .Miles:
                lengthType = .Meters
            case .Meters: fallthrough
            default:
                lengthType = .Miles
            }
        }
    }
    
    
    @IBAction func unitOfTempreturePress(sender: UIButton) {
        if tempratureType != nil {
            switch tempratureType! {
            case .Fahrenheit:
                tempratureType = .Kelvin
            case .Kelvin:
                tempratureType = .Celsius
            case .Celsius: fallthrough
            default:
                tempratureType = .Fahrenheit
            }
        }
    }
    
    // MARK: Gestures
    
    @IBAction func swipeGesture(sender: UISwipeGestureRecognizer) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let tabBarController = appDelegate.window?.rootViewController as? UITabBarController {
                
                switch sender.direction {
                case UISwipeGestureRecognizerDirection.Left: tabBarController.selectedIndex = 0
                case UISwipeGestureRecognizerDirection.Right: tabBarController.selectedIndex = 1
                default: break
                }
            }
        }
    }

}
