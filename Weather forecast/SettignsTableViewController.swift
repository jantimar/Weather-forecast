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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // show actual states on buttons
        if let lengthUnit = defaults.stringForKey("LengthUnit") {
            lengthButton.setTitle(lengthUnit, forState: .Normal)
        }
        
        if let tempratureUnit = defaults.stringForKey("TempratureUnit") {
            tempretureButton.setTitle(tempratureUnit, forState: .Normal)
        }
    }
    
    // MARK: Buttons press 
    
    @IBAction func lengthUnitPress(sender: UIButton) {
        
        switch sender.titleForState(.Normal)! {
        case "Miles":
            sender.setTitle("Meters", forState: .Normal)
            defaults.setValue("Meters", forKey: "LengthUnit")
        case "Meters": fallthrough
        default:
            sender.setTitle("Miles", forState: .Normal)
            defaults.setValue("Miles", forKey: "LengthUnit")
            
        }
    }
    
    
    @IBAction func unitOfTempreturePress(sender: UIButton) {
        switch sender.titleForState(.Normal)! {
        case "Fahrenheit":
            sender.setTitle("Celsius", forState: .Normal)
            defaults.setValue("Celsius", forKey: "TempratureUnit")
        case "Kelvin":
            sender.setTitle("Fahrenheit", forState: .Normal)
            defaults.setValue("Fahrenheit", forKey: "TempratureUnit")
        case "Celsius": fallthrough
        default:
            sender.setTitle("Kelvin", forState: .Normal)
            defaults.setValue("Kelvin", forKey: "TempratureUnit")
            
        }
        
    }
    
}
