//
//  WeekForecastCell.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/21/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit

class WeekForecastCell: UITableViewCell {
    @IBOutlet weak var iconIm: UIImageView!
    @IBOutlet weak var dayNameLb: UILabel!
    @IBOutlet weak var tempLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
