//
//  TodayViewController.swift
//  WidgetWeather
//
//  Created by Lê Duy on 5/28/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit
import CoreLocation
import SDWebImage

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descriptionLb: UILabel!
    @IBOutlet weak var feelLikeLb: UILabel!
    @IBOutlet weak var locationLb: UILabel!
    @IBOutlet weak var tempertureLb: UILabel!
    
    
    @IBOutlet weak var containerView: UIView!
    
    var getWeatherFacade:WeatherDataRequest?
    var result: CurrentWeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func updateUI(result: CurrentWeatherData){
        DispatchQueue.main.async {
            guard let main = result.main else {fatalError()}
            guard let weather = result.getWeather() else {fatalError()}
            guard let description = result.getWeather()?.description else {fatalError()}
            
            let temp = Int((main.temp ?? 273.15) - 273.15)
            let tempFeel = Int((main.feels_like ?? 273.15) - 273.15)
            
            self.descriptionLb.text = description.capitalizingFirstLetter()
            self.tempertureLb.text = "\(temp)°"
            self.feelLikeLb.text = "Feel like: \(tempFeel)°"
            if let url = URL(string: ApiKey.getIconAPI(iconName: weather.icon ?? "")) {
                self.weatherIcon.sd_setImage(with: url, completed: nil)
            } else {
                fatalError("Can't get icon url.")
            }
            self.locationLb.text = "Tp.Hà Nội"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let rs = self.result {
            self.updateUI(result: rs)
        } else {
            if let currentLocation = getCurrentLocation() {
                getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                    self.result = result
                    self.updateUI(result: result)
                }
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    private func getWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)){
        
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getCurrentWeatherData { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
        
    }
    
    var locManager = CLLocationManager()
    private func getCurrentLocation() -> CLLocationCoordinate2D? {
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation?
        
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
        if let current = currentLocation {
            let coordinate = current.coordinate
            
            return coordinate
            
        } else {
            return nil
        }
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
