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

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        
    }
    
    private func initView(){
        var locManager = CLLocationManager()
        var currentLocation: CLLocation?
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            currentLocation = locManager.location
        }
        
        print(currentLocation?.coordinate.longitude)
        print(currentLocation?.coordinate.latitude)
        
        if let coordinate = currentLocation?.coordinate {
            print(coordinate.longitude)
            let initialLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            centerMapOnLocation(location: initialLocation)
            setupUI(coordinate: coordinate)
        }
    }

    //MARK: - Helper Functions
    let regionRadius: CLLocationDistance = 1000
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    //MARK: - Add an annotation
    private func setupUI(coordinate: CLLocationCoordinate2D){
        let _annotation = MyAnnotation(title: "Lê Duy", locationName: "What?", discipline: "blala", coordinate: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
        mapView.addAnnotation(_annotation)
    }
}

