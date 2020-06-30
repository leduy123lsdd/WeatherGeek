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
import SDWebImage
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var placeLb: UILabel!
    @IBOutlet weak var dateTimeLb: UILabel!
    @IBOutlet weak var weatherSumLb: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var centerVerticalXImage: NSLayoutConstraint!
    
    var searchAddressVC:SearchAddressVC! = nil
    
    var getWeatherFacade:WeatherDataRequest?
    var getWeatherDataServiceResponse:CurrentWeatherData?
    var getHourlyDataServiceResponde:CurrentWeatherData?
    var getWeekWeatherDataService:CurrentWeatherData?
    
    // Slide variables
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    
    let cardHeight:CGFloat = 600
    let cardHandleAreaHeight:CGFloat = 140
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var region:[NSManagedObject] = []
    var currentSearchedLocation:CLLocation?
    var regionName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchAddressVC = storyboard!.instantiateViewController(identifier: "SearchAddressVC") as? SearchAddressVC
        searchAddressVC.searchAddVCDelegate = self
        setupCard()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.appDelegate = self
        
        if let currentLocation = getCurrentLocation() {
            getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                self.updateUI(data: result)
                self.updateUICardView(data: result)
                self.getWeatherDataServiceResponse = result
            }
            self.getHourlyWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                self.getHourlyDataServiceResponde = data
                self.updateUICardView(dataHourlyForecast: data)
            }
            self.getWeekWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                self.getWeatherDataServiceResponse = data
                self.updateUICardView(dataWeekForecast: data)
            }
        }
        
//        save(lat: 12.2323, lon: 123.2323, regionName: "hanoi")
//        save(lat: 12.2323, lon: 123.2323, regionName: "Hanoi")
//
        
        
        fetchData { (data) in
            self.region = data
            for dt in self.region {
////                print(dt.value(forKey: "lat"))
////                print(dt.value(forKey: "lon"))
                print(dt.value(forKey: "regionname"))
//                self.deleteData(deleteObject: dt)
            }
        }
        
//        deleteData(deleteObject: region[0])
    }
    
    func changeIcon(iconName:String){
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(iconName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if getWeatherDataServiceResponse == nil {
            if let currentLocation = getCurrentLocation() {
                getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                    self.updateUI(data: result)
                    self.updateUICardView(data: result)
                }
                self.getHourlyWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                    self.getHourlyDataServiceResponde = data
                    self.updateUICardView(dataHourlyForecast: data)
                }
                self.getWeekWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                    self.getWeatherDataServiceResponse = data
                    self.updateUICardView(dataWeekForecast: data)
                }
            }
        }
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        self.navigationController?.pushViewController(searchAddressVC, animated: true)
    }
    
    //MARK: - add location book mark
    @IBAction func bookMarkLocationAction(_ sender: Any) {
        if let location = currentSearchedLocation {
            let coordinate = location.coordinate
            self.save(lat: coordinate.latitude, lon: coordinate.longitude, regionName: self.regionName)
            _ = Alert.showAlert(on: self, withTitle: "Save successed!", message: "")
        }
    }
    
    //MARK: - services
    private func getWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)){
        self.currentSearchedLocation = CLLocation(latitude: lat, longitude: lon)
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getCurrentWeatherData { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
    }
    
    private func getHourlyWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)) {
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getHourlyWeatherData { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
        
    }
    
    private func getWeekWeatherDataService(lat:Double,lon:Double,completion: @escaping((_ dataResponse: CurrentWeatherData)->Void)) {
        self.getWeatherFacade = WeatherDataRequest(lat: lat, lon: lon)
        self.getWeatherFacade?.getWeekWeather { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let weatherData):
                completion(weatherData)
            }
        }
        
    }
    
    private func updateUI(data:CurrentWeatherData, location:MKPlacemark? = nil) {
        DispatchQueue.main.async {
            
            guard let weather = data.getWeather() else {fatalError()}
            guard let name = data.name else {fatalError()}
            
            
            
            self.weatherSumLb.text = (weather.description ?? "Failed to load data.").capitalizingFirstLetter()
            
            if let id = weather.id {
                switch id {
                case 200...232:
                    self.imageWeather.image = UIImage(named: "Thunderstorm.png")
                    self.changeIcon(iconName: "Thunderstorm.png")
                case 300...321:
                    self.imageWeather.image = UIImage(named: "Drizzle.png")
                    self.changeIcon(iconName: "Drizzle.png")
                case 500...531:
                    self.imageWeather.image = UIImage(named: "Rain.png")
                    self.changeIcon(iconName: "Rain.png")
                case 600...622:
                    self.imageWeather.image = UIImage(named: "Snow.png")
                    self.changeIcon(iconName: "Snow.png")
                case 701...781:
                    self.imageWeather.image = UIImage(named: "Atmosphere.png")
                    self.changeIcon(iconName: "Atmosphere.png")
                case 800:
                    self.imageWeather.image = UIImage(named: "Clear.png")
                    self.changeIcon(iconName: "Clear.png")
                case 801...804:
                    self.imageWeather.image = UIImage(named: "Clouds.png")
                    self.changeIcon(iconName: "Clouds.png")
                default:
                    self.imageWeather.image = UIImage(named: "icons8-rainbow-500.png")
                    self.changeIcon(iconName: "icons8-rainbow-500.png")
                }
            }
            
            self.regionName = name
            self.placeLb.text = name
            
            // get the current date and time
            let currentDateTime = Date()

            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .long

            // get the date time String from the date object
            self.dateTimeLb.text = formatter.string(from: currentDateTime) // October 8, 2016 at 10:48:53 PM
            
            
            if let placemark = location, let city = placemark.locality, let nameCity = placemark.name {
                self.placeLb.fadeTransition(0.4)
                self.placeLb.text = "\(city), \(nameCity)"
                self.regionName = city
            }
        }
        
    }
    
    private func updateUICardView(data:CurrentWeatherData? = nil, dataHourlyForecast:CurrentWeatherData? = nil, dataWeekForecast:CurrentWeatherData? = nil) {
        if let data = data {
            self.cardViewController.parseData(data: data)
        }
        if let data2 = dataHourlyForecast {
            self.cardViewController.parseForecast(data: data2)
        }
        if let data3 = dataWeekForecast {
            self.cardViewController.parseWeekForecast(data: data3)
        }
    }
    
    //MARK: - get current location
    var locManager = CLLocationManager()
    private func getCurrentLocation() -> CLLocationCoordinate2D? {
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
            
            return coordinate
            
        } else {
            return nil
        }
    }
    
    //MARK: - set up card view
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
        
//        _ = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleCardTap(recognize:)))
        let panGestureRezognizer = UIPanGestureRecognizer(target: self, action: #selector(HomeViewController.handleCardPan(recognize:)))
        
        cardViewController.view.addGestureRecognizer(panGestureRezognizer)
        
        self.visualEffectView.isUserInteractionEnabled = false
        
        cardViewController.view.layer.masksToBounds = false
        cardViewController.view.layer.shadowColor = UIColor.black.cgColor
        cardViewController.view.layer.shadowOpacity = 0.2
        cardViewController.view.layer.shadowOffset = .zero
        cardViewController.view.layer.shadowRadius = 3
        
    }
    
    //MARK: - save, fetch, delete data in core data
    func save(lat:Double, lon:Double, regionName:String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: managedContext)!
        let region = NSManagedObject(entity: entity, insertInto: managedContext)
        region.setValue(lat, forKey: "lat")
        region.setValue(lon, forKey: "lon")
        region.setValue(regionName, forKey: "regionname")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error at saving location data: \(error)")
        }
    }
    
    func fetchData(dataReturn:((_ data:[NSManagedObject])->Void)?){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Region")
        do {
            region = try managedContext.fetch(fetchRequest)
            if let completion = dataReturn {
                completion(region)
            }
        } catch let error as NSError {
            print("error at fetch data from region entity: \(error)")
        }
    }
    
    func deleteData(deleteObject:NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            managedContext.delete(deleteObject)
            try managedContext.save()
        } catch let error as NSError {
            print("Error at delete data: \(error)")
        }
    }
}

extension HomeViewController: AppDidWake {
    func appBecomeActive() {
        if let currentLocation = getCurrentLocation() {
            getWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (result) in
                self.updateUI(data: result)
                self.updateUICardView(data: result)
                self.getWeatherDataServiceResponse = result
            }
            self.getHourlyWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                self.getHourlyDataServiceResponde = data
                self.updateUICardView(dataHourlyForecast: data)
            }
            self.getWeekWeatherDataService(lat: currentLocation.latitude, lon: currentLocation.longitude) { (data) in
                self.getWeatherDataServiceResponse = data
                self.updateUICardView(dataWeekForecast: data)
            }
        }
    }
}




//MARK: - set up slide view
extension HomeViewController {
    @objc
    func handleCardTap(recognize: UITapGestureRecognizer) {
        
    }
    
    @objc
    func handleCardPan(recognize: UIPanGestureRecognizer) {
        switch recognize.state {
        case .began:
            // startTransition
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // updateTransistion
            let translation = recognize.translation(in: self.cardViewController.view)
            var fractionComplete = translation.y/cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            
            runningAnimations.append(blurAnimator)
        }
    }
    
    func startInteractiveTransition(state: CardState, duration:TimeInterval ) {
        if runningAnimations.isEmpty {
            // run animations
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}

extension HomeViewController: PutBackNewLocation {
    func newLocation(location: MKPlacemark) {
        let coordinate = location.coordinate
        self.getWeatherDataService(lat: coordinate.latitude, lon: coordinate.longitude) { (result) in
            self.getWeatherDataServiceResponse = result
            self.updateUI(data: result, location: location)
            self.updateUICardView(data: result)
            
        }
        self.getHourlyWeatherDataService(lat: coordinate.latitude, lon: coordinate.longitude) { (data) in
            self.getHourlyDataServiceResponde = data
            self.updateUICardView(dataHourlyForecast: data)
        }
        self.getWeekWeatherDataService(lat: coordinate.latitude, lon: coordinate.longitude) { (data) in
            self.getWeatherDataServiceResponse = data
            self.updateUICardView(dataWeekForecast: data)
        }
    }
}
