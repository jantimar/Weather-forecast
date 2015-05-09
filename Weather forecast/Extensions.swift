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
        
        return lowercaseString.stringByReplacingCharactersInRange(lowercaseString.startIndex...lowercaseString.startIndex, withString: String(lowercaseString[lowercaseString.startIndex]).uppercaseString)
    }
}