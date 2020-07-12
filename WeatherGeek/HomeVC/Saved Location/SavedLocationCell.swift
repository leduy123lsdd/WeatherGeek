//
//  SavedLocationCell.swift
//  WeatherGeek
//
//  Created by Lê Duy on 7/1/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit
import CoreData

class SavedLocationCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var regionName: UILabel!
    @IBOutlet weak var tempratureLb: UILabel!
    var getWeatherFacade:WeatherDataRequest?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func parseData(data:NSManagedObject){
        DispatchQueue.global().async {
            let region = data.value(forKey: "regionname") as! String
            let lat = data.value(forKey: "lat") as! Double
            let lon = data.value(forKey: "lon") as! Double
            
            self.getWeatherDataService(lat: lat, lon: lon) { (data) in
                guard let main = data.main else {fatalError()}
                let temp = Int((main.temp ?? 273.15) - 273.15)
                
                DispatchQueue.main.async {
                    self.tempratureLb.text = "\(temp)°"
                    self.regionName.text = region
                }
            }
        }
    }
    
    private func getWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)){
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getCurrentWeatherData { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
    }
    
    
}
