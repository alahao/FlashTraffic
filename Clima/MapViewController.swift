//  ViewController.swift
//  MapApp
//  Created by Zi Wang on 23/08/2015.
//  Copyright (c) 2015 PrettyMotion. All rights reserved.

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData

class MapViewController: UIViewController, SetAddressDelegate {
    // Constants
    let GOOGLEMAP_API_URL = "https://maps.googleapis.com/maps/api/directions/json"
    let APP_KEY = "AIzaSyDeW72YFPFM9l9FI8amIEqRlr2XdOktm-M"
    var highwayParams : [String: String] = [:] //Dictionary
    var localParams : [String: String] = [:]   //Dictionary

    
    // Data Model and Core Data Model
    var coreDataModel : [MapDataModel] = []  //Created an empty coreDataModel object (Dictionary) using MapDataModel class
    var mapDataModel = MapDataModel() //Created mapDataModel object using MapDataModel class
    
    // Pre-linked IBOutlets
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var highwayDurationLabel: UILabel!
    @IBOutlet weak var localDurationLabel: UILabel!
    @IBOutlet weak var viaHwyLabel: UILabel!
    @IBOutlet weak var viaLocalLabel: UILabel!
    
    
// MARK: - Refresh Method
/***************************************************************/
    // 1. Refresh Button Pressed
    @IBAction func refreshPressed(_ sender: Any) {
        localDurationLabel.text = "Loading..."
        highwayDurationLabel.text = "Loading..."
        fetchCoreData()
        print("Alert 1: Refresh Button Pressed")
    }
    
    // 2. Refresh on Wake
    func applicationDidBecomeActive(_ application: UIApplication) {
        fetchCoreData()
        print("Alert 2: Refresh on Wake")
    }
   
    // 3. Refresh on View Loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoreData()
        print("Alert 3: Refresh on View Loaded")
    }
    
    
// MARK: - Change City Delegate methods
/***************************************************************/
    // Locations from page 2
    func userEnteredNewAddress(originAddress: String, originName: String, destinationAddress: String, destinationName: String) {
        highwayParams = ["origin" : originAddress, "destination" : destinationAddress, "departure_time" : "now", "key" : APP_KEY]
        localParams = ["origin" : originAddress, "destination" : destinationAddress, "departure_time" : "now", "avoid" : "highways", "key" : APP_KEY]
        mapDataModel.originName = originName
        mapDataModel.destinationName = destinationName
        
        
        getMapData(url: GOOGLEMAP_API_URL, highwayParameters: highwayParams, localParameters: localParams)
    }

    
    
// MARK: - Networking
/***************************************************************/
    // Get Data from Google
    func getMapData(url: String, highwayParameters: [String: String],  localParameters: [String: String]){
        
    // 4 - 5. Highway
        Alamofire.request(url, method: .get, parameters: highwayParameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Alert 4: Sucess! Got the Highway Map Data")
                let highwayMapJSON : JSON = JSON(response.result.value!)
                print(highwayMapJSON)
                self.updateHighwayMapData(highwayJSON: highwayMapJSON)

            } else {
                print("Alert 5: Error \(String(describing: response.result.error))")
                self.highwayDurationLabel.text = "Connection Issues"
            }
        }
        
    // 6 - 7. Local
        Alamofire.request(url, method: .get, parameters: localParameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Alert 6: Sucess! Got the Local Map Data")
                
                let localMapJSON : JSON = JSON(response.result.value!)
                print(localMapJSON)
                self.updateLocalMapData(localJSON: localMapJSON)
                
            } else {
                print("Alert 7: Error \(String(describing: response.result.error))")
                self.localDurationLabel.text = "Connection Issues"
            }
        }
        
    }
        
// MARK: - JSON Parsing
/***************************************************************/
        // 8. Translate JSON to HIGHWAY duration.
        func updateHighwayMapData(highwayJSON : JSON) {
            if let highwayDurationResult = highwayJSON["routes"][0]["legs"][0]["duration_in_traffic"]["text"].string {
                mapDataModel.highwayDuration = highwayDurationResult
                mapDataModel.highwayVia = highwayJSON["routes"][0]["summary"].stringValue
                print("Alert 8: HighwayDurationResult is \(highwayDurationResult)")
            } else { highwayDurationLabel.text = "Data Unavailable" }
            updateUIWithMapData()
        }
        
        // 9 - 10. Translate JSON to LOCAL duration.
        func updateLocalMapData(localJSON : JSON) {
            if let localDurationResult = localJSON["routes"][0]["legs"][0]["duration_in_traffic"]["text"].string {
                mapDataModel.localDuration = localDurationResult
                mapDataModel.origins = localJSON["routes"][0]["legs"][0]["start_address"].stringValue
                mapDataModel.destinations = localJSON["routes"][0]["legs"][0]["end_address"].stringValue
                mapDataModel.localVia = localJSON["routes"][0]["summary"].stringValue
                print("Alert 9: mapDataModel.origins is \(mapDataModel.origins)")
                print("Alert 10: LocalDurationResult is \(localDurationResult)")
            } else { localDurationLabel.text = "Data Unavailable" }
            
            // 11. Save Locations and Time to Core Data
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let mapCoreData = LocationCoreData(entity: LocationCoreData.entity(), insertInto: context)
                print("Alert 11A: mapDataModel origin is \(String(describing: mapDataModel.origins))")
                mapCoreData.origins = mapDataModel.origins
                mapCoreData.destinations = mapDataModel.destinations
                mapCoreData.lastUpdate = Date()
                mapCoreData.originName = mapDataModel.originName
                mapCoreData.destinationName = mapDataModel.destinationName
                
                
                try? context.save()
                print("Alert 11B: Last saved date is \(String(describing: mapCoreData.lastUpdate)), saved originName is \(String(describing: mapCoreData.originName))")
            }
            updateUIWithMapData()
        }
        
        
    
    

    // 12. Function for Fetch Core Data
    func fetchCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let mapCoreData = try? context.fetch(LocationCoreData.fetchRequest()) as? [LocationCoreData] {
                if mapCoreData?.last?.origins != nil {
                mapDataModel.origins = (mapCoreData?.last?.origins)!
                mapDataModel.destinations = (mapCoreData?.last?.destinations)!
                mapDataModel.lastUpdateTimeData = (mapCoreData?.last?.lastUpdate)!
                print("Alert 12: coreData Fetched, last update is \(mapDataModel.lastUpdateTimeData), originName is \(mapDataModel.originName)")
                } else {
                    highwayDurationLabel.text = "Location Empty"
                    localDurationLabel.text = "Location Empty"
                }
            }
        }
        userEnteredNewAddress(originAddress: mapDataModel.origins, originName: mapDataModel.originName, destinationAddress: mapDataModel.destinations, destinationName: mapDataModel.destinationName)
    }
    
  
    
// MARK: - UI Updates
/***************************************************************/
    func updateUIWithMapData() {
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short

        mapDataModel.lastUpdateTimeFormatted = formatter.string(from: mapDataModel.lastUpdateTimeData) // October 8, 2016 at 10:48:53 PM
        highwayDurationLabel.text = String(describing: mapDataModel.highwayDuration)
        localDurationLabel.text = String(describing: mapDataModel.localDuration)
        originLabel.text = "From \(mapDataModel.originName) to \(mapDataModel.destinationName)"

        lastUpdateLabel.text = "Updated: \(mapDataModel.lastUpdateTimeFormatted)"
        viaHwyLabel.text = String(describing: mapDataModel.highwayVia)
        viaLocalLabel.text = String(describing: mapDataModel.localVia)
    }
    

    // Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetAddressName" {
            let destinationVC = segue.destination as! SetAddressViewController
            destinationVC.delegate = self
        }
    }
}


