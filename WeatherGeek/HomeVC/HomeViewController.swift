//
//  ViewController.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/16/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var placeLb: UILabel!
    @IBOutlet weak var dateTimeLb: UILabel!
    @IBOutlet weak var weatherSumLb: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var degreeLb: UILabel!
    @IBOutlet weak var feelLikeNumLb: UILabel!
    @IBOutlet weak var cloudCoverNumLb: UILabel!
    @IBOutlet weak var windSpeedNumLb: UILabel!
    @IBOutlet weak var humidityNumLb: UILabel!
    
    
    @IBOutlet weak var centerVerticalXImage: NSLayoutConstraint!
    
    
    var searchAddressVC:SearchAddressVC! = nil
    var detailView: DetaiForecastViewController! = nil
    var settingView: SettingViewController! = nil
    
    var getWeatherFacade:WeatherDataRequest?
    var getWeatherDataServiceResponse:CurrentWeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchAddressVC = storyboard!.instantiateViewController(identifier: "SearchAddressVC") as? SearchAddressVC
        detailView = storyboard!.instantiateViewController(identifier: "DetaiForecastViewController") as? DetaiForecastViewController
        settingView = storyboard!.instantiateViewController(identifier: "SettingViewController") as? SettingViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.appDelegate = self
        
        if let currentLocation = getCurrentLocation() {
            getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                self.updateUI(data: result)
                self.getWeatherDataServiceResponse = result
            }
        }
        
//        DispatchQueue.main.async {
//            var reverse = false
//            while true {
//                reverse = !reverse
//                UIView.animate(withDuration: 0.4, animations: { [weak self] in
//                    self?.centerVerticalXImage.constant = (reverse ? 10 : -10)
//                }, completion: nil)            }
//
//
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = getWeatherDataServiceResponse {
            self.updateUI(data: data)
        } else {
            if let currentLocation = getCurrentLocation() {
                getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                    self.updateUI(data: result)
                }
            }
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        self.searchAddressVC.getLocationPin = { location in
            let coordinate = location.coordinate
            self.getWeatherDataService(lat: coordinate.latitude, lon: coordinate.longitude) { (result) in
                self.updateUI(data: result, location: location)
                self.getWeatherDataServiceResponse = result
            }
        }
        self.navigationController?.pushViewController(searchAddressVC, animated: true)
    }
    
    
    @IBAction func detailAndForecastBtnAction(_ sender: Any) {
        detailView.modalPresentationStyle = .formSheet
        
        self.present(detailView, animated: true, completion: nil)
    }
    
    
    @IBAction func settingBtnAction(_ sender: Any) {
        self.navigationController?.pushViewController(settingView, animated: true)
    }
    
    //MARK: - services
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
    
    private func updateUI(data:CurrentWeatherData, location:MKPlacemark? = nil) {
        DispatchQueue.main.async {
            guard let weather = data.getWeather() else {fatalError()}
            guard let main = data.main else {fatalError()}
            guard let wind = data.wind else {fatalError()}
            guard let cloud = data.clouds else {fatalError()}
            
            let temp = Int((main.temp ?? 273.15) - 273.15)
            let tempFeel = Int((main.feels_like ?? 273.15) - 273.15)
            let windSpeed = Int((wind.speed ?? 0) * 2.237)
            
            self.weatherSumLb.fadeTransition(0.4)
            self.degreeLb.fadeTransition(0.4)
            self.cloudCoverNumLb.fadeTransition(0.4)
            self.feelLikeNumLb.fadeTransition(0.4)
            self.windSpeedNumLb.fadeTransition(0.4)
            self.humidityNumLb.fadeTransition(0.4)
                    
            self.weatherSumLb.text = weather.description ?? "Failed to load data."
            self.degreeLb.text = "\(temp)°"
            self.cloudCoverNumLb.text = "\(cloud.all ?? 0) %"
            self.feelLikeNumLb.text = "\(tempFeel)°"
            self.windSpeedNumLb.text = "\(windSpeed) mph"
            self.humidityNumLb.text = "\(Int(main.humidity ?? 0)) %"
            
            if let url = URL(string: ApiKey.getIconAPI(iconName: weather.icon ?? "")) {
                self.imageWeather.sd_setImage(with: url, completed: nil)
            } else {
                fatalError("Can't get icon url.")
            }
            
            if let placemark = location, let city = placemark.locality, let nameCity = placemark.name {
                self.placeLb.fadeTransition(0.4)
                self.placeLb.text = "\(city), \(nameCity)"
            }
        }
        
        
    }
    
    //MARK: - get current location
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

extension HomeViewController: AppDidWake {
    func appBecomeActive() {
        if let currentLocation = getCurrentLocation() {
            getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                self.updateUI(data: result)
            }
        }
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.default)
        animation.type = CATransitionType.moveIn
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
