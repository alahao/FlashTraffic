//  ViewController.swift
//  MapApp
//
//  Created by Zi Wang on 23/08/2015.
//  Copyright (c) 2015 PrettyMotion. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData


class MapViewController: UIViewController, SetAddressDelegate {
    //Constants
    let GOOGLEMAP_API_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
    let APP_KEY = "AIzaSyD7v5q-NhVfrPKU1GcIGnTjuW1ghsLcEGo"
    var originDurationText = "Loading..."
    var destinationDurationText = "Loading..."
    var highwayParams : [String: String] = [:]
    var localParams : [String: String] = [:]

    //TODO: Declare instance variables here
    var mapDataModel = MapDataModel()
    
    func saveData() {
        
    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
        
        let mapDataModel = LocationCoreData(entity: LocationCoreData.entity(), insertInto: context)
        try? context.save()
    }
        
    }
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var highwayDurationLabel: UILabel!
    @IBOutlet weak var localDurationLabel: UILabel!
    @IBAction func refreshPressed(_ sender: Any) {
        localDurationLabel.text = "Loading..."
        highwayDurationLabel.text = "Loading..."
        getMapData(url: GOOGLEMAP_API_URL, highwayParameters: highwayParams, localParameters: localParams)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    //Write the getWeatherData method here:
    
    func getMapData(url: String, highwayParameters: [String: String],  localParameters: [String: String]){
        
        Alamofire.request(url, method: .get, parameters: highwayParameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Sucess! Got the Map Data")
                
                let highwayMapJSON : JSON = JSON(response.result.value!)
                print(highwayMapJSON)
                self.updateHighwayMapData(highwayJSON: highwayMapJSON)
                
            } else {
                print("Error \(response.result.error)")
                self.highwayDurationLabel.text = "Connection Issues"
            }
        }
        
        Alamofire.request(url, method: .get, parameters: localParameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Sucess! Got the Map Data")
                
                let localMapJSON : JSON = JSON(response.result.value!)
                print(localMapJSON)
                self.updateLocalMapData(localJSON: localMapJSON)
                
            } else {
                print("Error \(response.result.error)")
                self.localDurationLabel.text = "Connection Issues"
            }
        }
        
    }
   
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateHighwayMapData(highwayJSON : JSON) {
        
        if let highwayDurationResult = highwayJSON["rows"][0]["elements"][0]["duration_in_traffic"]["text"].string {
    
        mapDataModel.highwayDuration = highwayDurationResult
        mapDataModel.origins = highwayJSON["origin_addresses"].stringValue
        mapDataModel.destinations = highwayJSON["destination_addresses"].stringValue
        print("durationResult is \(highwayDurationResult)")
        saveData()
        updateUIWithMapData()
        
        }
        else {
            localDurationLabel.text = "Data Unavailable"
            highwayDurationLabel.text = "Data Unavailable"
        }
    }
    
    func updateLocalMapData(localJSON : JSON) {
        
        if let localDurationResult = localJSON["rows"][0]["elements"][0]["duration_in_traffic"]["text"].string {
            
            mapDataModel.localDuration = localDurationResult
            mapDataModel.origins = localJSON["origin_addresses"].stringValue
            mapDataModel.destinations = localJSON["destination_addresses"].stringValue
            print("durationResult is \(localDurationResult)")
            updateUIWithMapData()
            
        }
        else {
            localDurationLabel.text = "Data Unavailable"
            highwayDurationLabel.text = "Data Unavailable"
        }
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithMapData() {
        
        highwayDurationLabel.text = String(describing: mapDataModel.highwayDuration)
        localDurationLabel.text = String(describing: mapDataModel.localDuration)
        print("Highway duration is \(mapDataModel.highwayDuration)")
        print("Local duration is \(mapDataModel.localDuration)")

    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    //Write the userEnteredANeworiginAddress Delegate method here:
    func userEnteredNewAddress(originAddress: String, destinationAddress: String) {
        highwayParams = ["origins" : originAddress, "destinations" : destinationAddress, "departure_time" : "now", "key" : APP_KEY]
        localParams = ["origins" : originAddress, "destinations" : destinationAddress, "departure_time" : "now", "avoid" : "highways", "key" : APP_KEY]
        originDurationText = originAddress
        destinationDurationText = destinationAddress
        getMapData(url: GOOGLEMAP_API_URL, highwayParameters: highwayParams, localParameters: localParams)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetAddressName" {
            let destinationVC = segue.destination as! SetAddressViewController
            
            destinationVC.delegate = self
        }
    }
}


