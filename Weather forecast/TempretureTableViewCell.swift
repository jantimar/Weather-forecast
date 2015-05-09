//
//  TempretureTableViewCell.swift
//  Weather forecast
//
//  Created by Jan Timar on 8.5.2015.
//  Copyright (c) 2015 Jan Timar. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TempretureTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    @IBOutlet weak var tempratureLabel: UILabel!

}
