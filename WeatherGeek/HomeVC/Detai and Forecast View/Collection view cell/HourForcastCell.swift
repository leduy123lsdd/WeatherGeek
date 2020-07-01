//
//  HourForcastCell.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/21/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit
import SDWebImage

class HourForcastCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLb: UILabel!
    @IBOutlet weak var iconIm: UIImageView!
    @IBOutlet weak var temperatureLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateUI(label: String,icon:String,temp:String) {
        DispatchQueue.main.async {
            self.hourLb.text = label
            self.temperatureLb.text = temp
            if let url = URL(string: ApiKey.getIconAPI(iconName: icon)) {
                self.iconIm.sd_setImage(with: url, completed: nil)
            } else {
                fatalError("Can't get icon url.")
            }
        }
    }
}
