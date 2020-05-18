//
//  CurrentWeatherData.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/18/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation

class CurrentWeatherData: Decodable {
    var weather:[Weather]?
    var main:Main?
    var wind:Wind?
    var clouds:Cloud?
    
    func getWeather() -> Weather? {
        if self.weather!.count > 0 {
            return (self.weather?.first!)!
        }
        return nil
    }
}

class Weather: Decodable {
    var icon:String?
    var description:String?
}

class Main: Decodable {
    var temp:Double?
    var humidity:Double?
    var feels_like:Double?
}

class Wind: Decodable {
    var speed:Double?
}

class Cloud: Decodable {
    var all:Int?
}
