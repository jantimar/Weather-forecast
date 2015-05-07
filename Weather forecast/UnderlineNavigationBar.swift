//
//  UnderlineNavigationBar.swift
//  Weather forecast
//
//  Created by Jan Timar on 6.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit

class UnderlineNavigationBar: UINavigationBar {

    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let colorUnderline = UIImage(named: "Color_line") {
            setUnderNavigationBarImage(colorUnderline)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let colorUnderline = UIImage(named: "Color_line") {
            setUnderNavigationBarImage(colorUnderline)
        }
        
    }
    
    private func setUnderNavigationBarImage(let underLineImage: UIImage){
        let colorUndeLineImageView = UIImageView(image: underLineImage)
        
        self.addSubview(colorUndeLineImageView)
        
        colorUndeLineImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // set constraints
        let leftConstraint = NSLayoutConstraint(item: colorUndeLineImageView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0);
        addConstraint(leftConstraint);
        
        let rightConstraint = NSLayoutConstraint(item: colorUndeLineImageView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0);
        self.addConstraint(rightConstraint);
        
        let topConstraint = NSLayoutConstraint(item: colorUndeLineImageView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0);
        self.addConstraint(topConstraint);
    }

}
