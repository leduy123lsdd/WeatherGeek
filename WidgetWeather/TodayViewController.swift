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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var descriptionLb: UILabel!
    @IBOutlet weak var feelLikeLb: UILabel!
    @IBOutlet weak var locationLb: UILabel!
    @IBOutlet weak var tempertureLb: UILabel!
    
    var getWeatherFacade:WeatherDataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
//        if let currentLocation = getCurrentLocation() {
//            getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
//                self.updateUI(data: result)
//                self.updateUICardView(data: result)
//                self.getWeatherDataServiceResponse = result
//            }
//            self.getHourlyWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
//                self.getHourlyDataServiceResponde = data
//                self.updateUICardView(dataHourlyForecast: data)
//            }
//            self.getWeekWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
//                self.getWeatherDataServiceResponse = data
//                self.updateUICardView(dataWeekForecast: data)
//            }
//        }
        
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
