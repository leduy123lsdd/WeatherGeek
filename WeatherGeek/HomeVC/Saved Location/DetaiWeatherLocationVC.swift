
//
//  DetaiWeatherLocationVC.swift
//  WeatherGeek
//
//  Created by Lê Duy on 7/1/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit

class DetaiWeatherLocationVC: UIViewController {
    var lat:Double?
    var lon:Double?
    var getWeatherFacade:WeatherDataRequest?
    var dailyForcast = [Daily]()
    var hourlyWeather = [Current]()
    var current:Current?
    
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var degreeLb: UILabel!
    @IBOutlet weak var feelLikeNumLb: UILabel!
    @IBOutlet weak var cloudCoverNumLb: UILabel!
    @IBOutlet weak var windSpeedNumLb: UILabel!
    @IBOutlet weak var humidityNumLb: UILabel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "HourForcastCell", bundle: nil), forCellWithReuseIdentifier: "HourForcastCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WeekForecastCell", bundle: nil), forCellReuseIdentifier: "WeekForecastCell")
        tableView.rowHeight = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _lat = self.lat, let _lon = self.lon {
            getWeatherDataService(lat: _lat , lon: _lon) { (data) in
                guard let name = data.name else {fatalError()}
                guard let main = data.main else {fatalError()}
                guard let wind = data.wind else {fatalError()}
                guard let cloud = data.clouds else {fatalError()}
                
                let temp = Int((main.temp ?? 273.15) - 273.15)
                let tempFeel = Int((main.feels_like ?? 273.15) - 273.15)
                let windSpeed = Int((wind.speed ?? 0) * 2.237)
                
                DispatchQueue.main.async {
                    self.currentLocation.text = name
                    self.degreeLb.text = "\(temp)°"
                    self.cloudCoverNumLb.text = "\(cloud.all ?? 0) %"
                    self.feelLikeNumLb.text = "\(tempFeel)°"
                    self.windSpeedNumLb.text = "\(windSpeed) mph"
                    self.humidityNumLb.text = "\(Int(main.humidity ?? 0)) %"
                }
            }
            getHourlyWeatherDataService(lat: _lat , lon: _lon) { (data) in
                if let hourlyData = data.hourly {
                    self.hourlyWeather = hourlyData
                }
                if let current = data.current {
                    self.current = current
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            getWeekWeatherDataService(lat: _lat , lon: _lon) { (data) in
                if let daily = data.daily {
                    self.dailyForcast = daily
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func setBackgroundColor(hexString:String){
        self.view.backgroundColor = UIColor(hexString: hexString)
    }
    
    func setLat_lon(lat:Double,lon:Double){
        self.lat = lat
        self.lon = lon
    }
    
    //MARK: - services
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
    
    private func getHourlyWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)) {
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getHourlyWeatherData { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
        
    }
    
    private func getWeekWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)) {
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getWeekWeather { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
        
    }
}

extension DetaiWeatherLocationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForcast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekForecastCell", for: indexPath) as! WeekForecastCell
        let data = dailyForcast[indexPath.row]
        let iconName = data.weather?.first?.icon ?? ""
        
        let dayName = data.getDayOfWeek()
        let temp = Int((data.temp?.day ?? 273.15) - 273.15)
        
        cell.dayNameLb.text = indexPath.row == 0 ? "Today" : dayName
        cell.dayNameLb.font = UIFont.boldSystemFont(ofSize: indexPath.row == 0 ? 24.0 : 20)
        cell.tempLb.text = "\(temp)°"
        
        if let url = URL(string: ApiKey.getIconAPI(iconName: iconName)) {
            cell.iconIm.sd_setImage(with: url, completed: nil)
        } else {
            fatalError("Can't get icon url.")
        }
        
        return cell
    }
}

extension DetaiWeatherLocationVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourForcastCell", for: indexPath) as! HourForcastCell
        let data = self.hourlyWeather[indexPath.row]
        let temp = Int((data.temp ?? 273.15) - 273.15)
        if indexPath.row == 0 {
            cell.updateUI(label: "Now" , icon: data.weather?.first?.icon ?? "", temp: "\(temp)°")
            cell.temperatureLb.font = UIFont.boldSystemFont(ofSize: 24.0)
            cell.hourLb.font = UIFont.boldSystemFont(ofSize: 24.0)
        } else {
            cell.updateUI(label: data.getHour()+"h" , icon: data.weather?.first?.icon ?? "", temp: "\(temp)°")
            cell.temperatureLb.font = UIFont.boldSystemFont(ofSize: 20.0)
            cell.hourLb.font = UIFont.boldSystemFont(ofSize: 20.0)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 128)
    }
}
