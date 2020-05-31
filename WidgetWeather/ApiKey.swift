//
//  ApiKey.swift
//  WidgetWeather
//
//  Created by Lê Duy on 5/29/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation

class ApiKey {
    static let API_KEY: String = "b5fa41a8a2329580a8447e09b138e7c4"
    
    static func getCurrentWeatherData_API(latitude: Double, longtitude: Double) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(ApiKey.API_KEY)"
    }
    static func getIconAPI(iconName:String) -> String {
        return "https://openweathermap.org/img/wn/\(iconName)@2x.png"
    }
}
