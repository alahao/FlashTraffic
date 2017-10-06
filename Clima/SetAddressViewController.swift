//
//  SetAddressViewController.swift
//  gMapApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

//Write the protocol declaration here:
protocol SetAddressDelegate {
    func userEnteredNewAddress (originAddress: String, destinationAddress: String)
}

class SetAddressViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate : SetAddressDelegate?
    
    //This is the pre-linked IBOutlets to the text field:

    @IBOutlet weak var SetOriginAddressTextField: UITextField!
    @IBOutlet weak var SetDestinationTextField: UITextField!
    
    //This is the IBAction that gets called when the user taps on the "Get gMap" button:
    @IBAction func setAddressPressed(_ sender: AnyObject) {
        
        
        
        let originTextInput = SetOriginAddressTextField.text!
        let destinationTextInput = SetDestinationTextField.text!
        
        delegate?.userEnteredNewAddress(originAddress: originTextInput, destinationAddress: destinationTextInput)
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //This is the IBAction that gets called when the user taps the back button.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
