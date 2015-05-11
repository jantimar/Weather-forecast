//
//  Extensions.swift
//  Weather forecast
//
//  Created by Jan Timar on 9.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import Foundation

extension String {
    func firstCharacterUpperCase() -> String {
        let lowercaseString = self.lowercaseString
        
        return count(self) > 1 ? lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString) : ""
    }
}

extension UILabel {
    func setTextWithAnimation(text: String) {
        UIView.transitionWithView(self, duration: Constants.AnimationDuration, options: .TransitionFlipFromTop, animations: { () -> Void in
            self.text = text
        }, completion: nil)
    }
}

extension UIButton {
    func setTextWithAnimation(text: String) {
        UIView.transitionWithView(self, duration: Constants.AnimationDuration, options: .TransitionFlipFromTop, animations: { () -> Void in
            self.setTitle(text, forState: .Normal)
            }, completion: nil)
    }
}

extension UIImage {
    static func weatherImage(description: String) -> UIImage? {
        let lowercaseDescription = description.lowercaseString
        if lowercaseDescription.rangeOfString("cloud") != nil {
            return UIImage(named: "Cloudy_Big")
        } else if lowercaseDescription.rangeOfString("light") != nil {
            return UIImage(named: "Lightning_Big")
        } else if lowercaseDescription.rangeOfString("wind") != nil {
            return UIImage(named: "WInd_Big")
        } else {
            return UIImage(named: "Sun_Big")
        }
  }
}

extension UIImageView {
    func setImageWithAnimation(image: UIImage?) {
        UIView.transitionWithView(self, duration: Constants.AnimationDuration, options: .TransitionFlipFromTop, animations: { () -> Void in
            self.image = image
        }, completion: nil)
    }
}

extension Float {
    func tempratureInFormatFromKelvin(to: SettignsTableViewController.TempratureType) -> String {
        switch to {
        case .Kelvin: return String(format:"%.1f",self)
        case .Fahrenheit: return String(format:"%.1f", TempratureConverter.convertTemperatures(self,  source:"Kelvin", target:"Fahrenheit"))
        case .Celsius: fallthrough
        default: return String(format:"%.1f", TempratureConverter.convertTemperatures(self,  source:"Kelvin", target:"Celsius"))
        }
    }
    
    func direction() -> String {
        if self > 348.75 || self <= 11.25 {
            return "N"
        } else if self > 11.2 && self <= 33.75 {
            return "NNE"
        } else if self > 33.75 && self <= 56.25 {
            return "NE"
        } else if self > 56.25 && self <= 78.75 {
            return "ENE"
        } else if self > 78.75 && self <= 101.25 {
            return "E"
        } else if self > 101.25 && self <= 123.75 {
            return "ESE"
        } else if self > 123.75 && self <= 146.25 {
            return "SE"
        } else if self > 146.25 && self <= 168.75 {
            return "SSE"
        } else if self > 168.75 && self <= 191.25 {
            return "S"
        } else if self > 191.25 && self <= 213.75 {
            return "SSW"
        } else if self > 213.75 && self <= 236.25 {
            return "SW"
        } else if self > 236.25 && self <= 258.75 {
            return "WSW"
        } else if self > 258.75 && self <= 281.25 {
            return "W"
        } else if self > 281.25 && self <= 303.75 {
            return "WNW"
        } else if self > 303.75 && self <= 326.25 {
            return "NW"
        } else if self > 326.25 && self <= 348.75 {
            return "NNW"
        } else {
            return "-"
        }
    }
}