//
//  MyAnnotationView.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/17/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import MapKit

class MyAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let _myAnnotation = newValue as? MyAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            markerTintColor = _myAnnotation.markerTintColor
            glyphText = String(_myAnnotation.discipline.first!)
        }
    }
}
