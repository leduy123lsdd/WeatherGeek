//
//  CardViewController.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/24/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var degreeLb: UILabel!
    @IBOutlet weak var feelLikeNumLb: UILabel!
    @IBOutlet weak var cloudCoverNumLb: UILabel!
    @IBOutlet weak var windSpeedNumLb: UILabel!
    @IBOutlet weak var humidityNumLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var hourlyWeather = [Current]()
    var current:Current?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view..self.weatherSumLb.fadeTransition(0.4)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "HourForcastCell", bundle: nil), forCellWithReuseIdentifier: "HourForcastCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WeekForecastCell", bundle: nil), forCellReuseIdentifier: "WeekForecastCell")
        tableView.rowHeight = 50
    }
    
    func parseData(data:CurrentWeatherData){
        DispatchQueue.main.async {
            guard let main = data.main else {fatalError()}
            guard let wind = data.wind else {fatalError()}
            guard let cloud = data.clouds else {fatalError()}
            
            let temp = Int((main.temp ?? 273.15) - 273.15)
            let tempFeel = Int((main.feels_like ?? 273.15) - 273.15)
            let windSpeed = Int((wind.speed ?? 0) * 2.237)
            
            self.degreeLb.text = "\(temp)°"
            self.cloudCoverNumLb.text = "\(cloud.all ?? 0) %"
            self.feelLikeNumLb.text = "\(tempFeel)°"
            self.windSpeedNumLb.text = "\(windSpeed) mph"
            self.humidityNumLb.text = "\(Int(main.humidity ?? 0)) %"
            
        }
    }
    
    func parseForecast(data: CurrentWeatherData) {
        DispatchQueue.main.async {
            if let hourlyData = data.hourly {
                self.hourlyWeather = hourlyData
            }
            if let current = data.current {
                self.current = current
            }
            self.collectionView.reloadData()
        }
    }
}

extension CardViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourForcastCell", for: indexPath) as! HourForcastCell
        let data = self.hourlyWeather[indexPath.row]
        let temp = Int((data.temp ?? 273.15) - 273.15)
        if indexPath.row == 0 {
            cell.updateUI(label: "Now" , icon: data.weather?.first?.icon ?? "", temp: "\(temp)°")
        } else {
            cell.updateUI(label: data.getHour()+"h" , icon: data.weather?.first?.icon ?? "", temp: "\(temp)°")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 110)
    }
}

extension CardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekForecastCell", for: indexPath) as! WeekForecastCell
        return cell
    }
    
    
}
