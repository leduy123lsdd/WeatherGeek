//
//  ApiKey.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/18/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation
import MapKit

class ApiKey {
    static let API_KEY: String = "b5fa41a8a2329580a8447e09b138e7c4"
    
    static func getCurrentWeatherData_API(latitude: Double, longtitude: Double) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(ApiKey.API_KEY)"
    }
    static func getIconAPI(iconName:String) -> String {
        return "https://openweathermap.org/img/wn/\(iconName)@2x.png"
    }
    static func getHourlyWeather(latitude: Double, longtitude: Double) -> String {
        let api = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longtitude)&exclude=minutely&appid=\(ApiKey.API_KEY)"
        return api
    }
    static func getWeekWeather(latitude: Double, longtitude: Double) -> String {
        let api = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longtitude)&exclude=minutely,hourly&appid=\(ApiKey.API_KEY)"
        return api
    }
}
