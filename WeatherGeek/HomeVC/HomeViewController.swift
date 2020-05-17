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
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }
    
    private func initView(){
        mapView.register(MyAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        showCurrentLocationPin()
        setUpSearchAddressResult()
    }

    //MARK: - Helper Functions
    let regionRadius: CLLocationDistance = 1000
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    //MARK: - Add an annotation
    private func setupUI(location: CLLocation, locationName:String = "", city:String = ""){
        let _annotation = MyAnnotation(title: "\(locationName)", locationName: "\(city)", discipline: "Me", coordinate: location.coordinate)
        mapView.addAnnotation(_annotation)
    }
    
    private func showCurrentLocationPin(){
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation?

        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
        if let current = currentLocation {
            let coordinate = current.coordinate
            let initialLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
            centerMapOnLocation(location: initialLocation)
            setupUI(location: initialLocation)
        }
    }
    
    private func setUpSearchAddressResult(){
        // Setup search results table
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "LocationSearchTableVC") as! LocationSearchTableVC
        locationSearchTable.handlerMapSearchDelegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        locationSearchTable.mapView = mapView
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.setShowsCancelButton(true, animated: true)
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
}


extension HomeViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        if let city = placemark.locality, let state = placemark.administrativeArea, let name = placemark.name {
            annotation.subtitle = "\(name), \(city) "
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
            let currentLocation = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
            centerMapOnLocation(location: currentLocation)
            setupUI(location: currentLocation, locationName: name, city: city)
            mapView.setRegion(region, animated: true)
        }
    }
}
