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
    var name:String?
    
    func getWeather() -> Weather? {
        if self.weather!.count > 0 {
            return (self.weather?.first!)!
        }
        return nil
    }
    
    var current:Current?
    var hourly:[Current]?
    
    var daily:[Daily]?
}

class Weather: Decodable {
    var icon:String?
    var id:Int?
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


class Current: Decodable {
    var dt:Double?
    var temp:Double?
    var weather:[Weather]?
    
    func getHour() -> String {
        if let dt = self.dt {
            let date = NSDate(timeIntervalSince1970: dt)
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "hh"

            let dateString = dayTimePeriodFormatter.string(from: date as Date)
            return dateString
        }
        return ""
    }
    
    
}

class Temp:Decodable {
    var day:Double?
}

class Daily:Decodable {
    var dt:Double?
    var temp:Temp?
    var weather:[Weather]?
    
    
    func getDayOfWeek() -> String {
        var today = ""
        
        if let dt = self.dt {
            let date = NSDate(timeIntervalSince1970: dt)
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd"

            let dateString = dayTimePeriodFormatter.string(from: date as Date)
            today = dateString
        } else {
            return ""
        }
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { fatalError("\nCan't get today date") }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        
        
        switch weekDay {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
}

