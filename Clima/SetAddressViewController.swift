//
//  SetAddressViewController.swift
//  gMapApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreData

//Write the protocol declaration here:
protocol SetAddressDelegate {
    func userEnteredNewAddress (originAddress: String, originName: String, destinationAddress: String, destinationName: String)
}

class SetAddressViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate : SetAddressDelegate?
    let mapDataModel = MapDataModel()
    //This is the pre-linked IBOutlets to the text field:

    @IBOutlet weak var SetOriginAddressTextField: UITextField!
    @IBOutlet weak var SetDestinationTextField: UITextField!
    @IBOutlet weak var setOriginNickNameTextField: UITextField!
    @IBOutlet weak var setDestinationNickNameTextField: UITextField!
    
    
    @IBAction func swapButton(_ sender: Any) {
        print("ALERT SET3 mapDataModel.originName is \(mapDataModel.originName)")
        SetOriginAddressTextField.text! = mapDataModel.destinations
        SetDestinationTextField.text! = mapDataModel.origins
        setOriginNickNameTextField.text! = mapDataModel.destinationName
        setDestinationNickNameTextField.text! = mapDataModel.originName
        
        mapDataModel.origins = SetOriginAddressTextField.text!
        mapDataModel.destinations = SetDestinationTextField.text!
        mapDataModel.originName = setOriginNickNameTextField.text!
        mapDataModel.destinationName = setDestinationNickNameTextField.text!
    }
    
    //View Did Load, fetch Core Data, display last saved info. 
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ALERT SET4 mapDataModel.originName is \(mapDataModel.originName)")
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let mapCoreData = try? context.fetch(LocationCoreData.fetchRequest()) as? [LocationCoreData] {
                if mapCoreData?.last?.origins != nil {
                    SetOriginAddressTextField.text = (mapCoreData?.last?.origins)!
                    SetDestinationTextField.text = (mapCoreData?.last?.destinations)!
                    setOriginNickNameTextField.text = (mapCoreData?.last?.originName)!
                    setDestinationNickNameTextField.text = (mapCoreData?.last?.destinationName)!
                    
                    mapDataModel.origins = (mapCoreData?.last?.origins)!
                    mapDataModel.destinations = (mapCoreData?.last?.destinations)!
                    mapDataModel.originName = (mapCoreData?.last?.originName)!
                    mapDataModel.destinationName = (mapCoreData?.last?.destinationName)!
                    
                   }
                }
            }
        print("ALERT SET5 mapDataModel.originName is \(mapDataModel.originName)")
        }
    
    //This is the IBAction that gets called when the user taps on the "Get gMap" button:
    @IBAction func setAddressPressed(_ sender: AnyObject) {
        
//        SetOriginAddressTextField.text! = SetOriginAddressTextField.placeholder!
//        SetDestinationTextField.text! = SetDestinationTextField.placeholder!
//        setOriginNickNameTextField.text! = setOriginNickNameTextField.placeholder!
//        setDestinationNickNameTextField.text! = setDestinationNickNameTextField.placeholder!
        let originTextInput = SetOriginAddressTextField.text!
        let destinationTextInput = SetDestinationTextField.text!
        
        mapDataModel.destinations = SetDestinationTextField.text!
        mapDataModel.origins = SetOriginAddressTextField.text!
        
        
       
        print("Alert Set1: Set DestinationName Label is \(String(describing: mapDataModel.destinationName))")
        delegate?.userEnteredNewAddress(originAddress: originTextInput, originName: setOriginNickNameTextField.text!, destinationAddress: destinationTextInput, destinationName: setDestinationNickNameTextField.text!)
   
        self.dismiss(animated: true, completion: nil)
        }
    
    
    //This is the IBAction that gets called when the user taps the back button.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
