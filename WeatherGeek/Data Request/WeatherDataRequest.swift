//
//  WeatherDataRequest.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/18/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation

enum WeatherDataError: Error {
    case noDataAvailable
    case canNotProcessData
}

struct WeatherDataRequest {
    var lat:Double?
    var lon:Double?
    
    init(lat:Double,lon:Double) {
        self.lat = lat
        self.lon = lon
    }
    
    mutating func set_lat_lon(lat:Double, lon:Double){
        self.lon = lon
        self.lat = lat
    }
    
    mutating func getCurrentWeatherData(completion: @escaping(Result<CurrentWeatherData, WeatherDataError>) -> Void){
        
        let resourceString = ApiKey.getCurrentWeatherData_API(latitude: self.lat ?? 0.0, longtitude: self.lon ?? 0.0)
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let holidaysResponse = try decoder.decode(CurrentWeatherData.self, from: jsonData)
                completion(.success(holidaysResponse))
            } catch let err {
                print(err)
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
    
    mutating func getHourlyWeatherData(completion: @escaping(Result<CurrentWeatherData, WeatherDataError>) -> Void){
        
        let resourceString = ApiKey.getHourlyWeather(latitude: self.lat ?? 0.0, longtitude: self.lon ?? 0.0)
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let holidaysResponse = try decoder.decode(CurrentWeatherData.self, from: jsonData)
                completion(.success(holidaysResponse))
            } catch let err {
                print(err)
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
    mutating func getWeekWeather(completion: @escaping(Result<CurrentWeatherData, WeatherDataError>) -> Void){
        
        let resourceString = ApiKey.getWeekWeather(latitude: self.lat ?? 0.0, longtitude: self.lon ?? 0.0)
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, _, _) in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let holidaysResponse = try decoder.decode(CurrentWeatherData.self, from: jsonData)
                completion(.success(holidaysResponse))
            } catch let err {
                print(err)
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
}
