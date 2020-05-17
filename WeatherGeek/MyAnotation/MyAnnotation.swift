//
//  MyAnotation.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/16/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    let title:String?
    let locationName:String
    let discipline:String
    let coordinate: CLLocationCoordinate2D
    
    init(title:String, locationName:String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.discipline = discipline
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // Market Tint Color for discipline
    var markerTintColor: UIColor {
        switch discipline {
        case "A":
            return .red
        case "B":
            return .blue
        default:
            return .systemPink
        }
    }
}
