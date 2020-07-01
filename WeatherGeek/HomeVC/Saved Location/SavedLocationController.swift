//
//  SavedLocationController.swift
//  WeatherGeek
//
//  Created by Lê Duy on 7/1/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import UIKit
import CoreData
class PresentDataInfo {
    var regionData:NSManagedObject?
    var color:String?
    init(region:NSManagedObject,color:String) {
        self.regionData = region
        self.color = color
    }
}

class SavedLocationController: UITableViewController {
    var region:[NSManagedObject] = []
    
    var data = [PresentDataInfo]()
    
    let color = ["#77212E","#9B1B30","#264E36","#9E1030","#7F4145","#006E6D","#BC70A4","#672E3B","#005960","#9E4624"]
    var indexColor = 0
    var detaiWeatherLocationVC:DetaiWeatherLocationVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "SavedLocationCell", bundle: nil), forCellReuseIdentifier: "SavedLocationCell")
        self.tableView.rowHeight = 80
        self.tableView.backgroundColor = UIColor.clear
        
        fetchData { (data) in
            self.data = [PresentDataInfo]()
            data.forEach { (item) in
                let dataTemp = PresentDataInfo(region: item, color: self.color[Int.random(in: 0 ..< self.color.count)])
                self.data.append(dataTemp)
            }
            self.region = data
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocationCell", for: indexPath) as! SavedLocationCell
        let regionData = data[indexPath.row]
        
        cell.containerView.backgroundColor = UIColor(hexString: regionData.color!)
        cell.parseData(data: regionData.regionData!)
        return cell
    }
    
    func fetchData(dataReturn:((_ data:[NSManagedObject])->Void)?){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Region")
        do {
            let regionData = try managedContext.fetch(fetchRequest)
            if let completion = dataReturn {
                completion(regionData)
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(deleteObject: data[indexPath.row].regionData!)
            fetchData { (data) in
                self.data = [PresentDataInfo]()
                data.forEach { (item) in
                    let dataTemp = PresentDataInfo(region: item, color: self.color[Int.random(in: 0 ..< self.color.count)])
                    self.data.append(dataTemp)
                }
                self.region = data
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentLocationData = data[indexPath.row].regionData!
        let lat = currentLocationData.value(forKey: "lat") as! Double
        let lon = currentLocationData.value(forKey: "lon") as! Double
        
        detaiWeatherLocationVC = storyboard!.instantiateViewController(identifier: "DetaiWeatherLocationVC") as? DetaiWeatherLocationVC
        detaiWeatherLocationVC?.setBackgroundColor(hexString: self.data[indexPath.row].color!)
        detaiWeatherLocationVC?.setLat_lon(lat: lat, lon: lon)
        self.navigationController?.pushViewController(detaiWeatherLocationVC!, animated: true)
    }
    
}
