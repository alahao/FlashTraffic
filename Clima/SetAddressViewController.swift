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
        SetOriginAddressTextField.text! = SetDestinationTextField.placeholder!
        SetDestinationTextField.text! = SetOriginAddressTextField.placeholder!
        
        mapDataModel.origins = SetDestinationTextField.text!
        mapDataModel.destinations = SetOriginAddressTextField.text!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let mapCoreData = try? context.fetch(LocationCoreData.fetchRequest()) as? [LocationCoreData] {
                if mapCoreData?.last?.origins != nil {
                    SetOriginAddressTextField.placeholder = (mapCoreData?.last?.origins)!
                    SetDestinationTextField.placeholder = (mapCoreData?.last?.destinations)!
                    setOriginNickNameTextField.placeholder = (mapCoreData?.last?.originName)!
                    setDestinationNickNameTextField.placeholder = (mapCoreData?.last?.destinationName)!
                   }
                }
            }
        }
    
    //This is the IBAction that gets called when the user taps on the "Get gMap" button:
    @IBAction func setAddressPressed(_ sender: AnyObject) {
        
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
