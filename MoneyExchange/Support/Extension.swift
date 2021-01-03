//
//  Extension.swift
//  MoneyExchange
//
//  Created by Chien on 2021/1/4.
//  Copyright © 2021 Chien. All rights reserved.
//

import UIKit

extension Double {

    // Function for Rounding double to decimal places value
    func roundToPlaces(toDigit digitNum: Int) -> Double {
        
        let divisor = pow(10.0, Double(digitNum))
        return (self * divisor).rounded() / divisor
    }
}

extension UIColor {

    // Function for Setting Color Using Hex Code
    convenience init(hexCode: Int) {

        let redValue = (hexCode >> 16) & 0xFF
        let greenValue = (hexCode >> 8) & 0xFF
        let blueValue = hexCode & 0xFF
        
        assert(redValue >= 0 && redValue <= 255, "Invalid Red Value")
        assert(greenValue >= 0 && greenValue <= 255, "Invalid Green Value")
        assert(blueValue >= 0 && blueValue <= 255, "Invalid Blue Value")
        
        self.init(red: CGFloat(redValue) / 255, green: CGFloat(greenValue) / 255, blue: CGFloat(blueValue) / 255, alpha: 1)
    }
}

extension UIView {
    
    // Function for Rounding Corner Easily
    func roundedCorner(by radius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .clear) {
        
        self.clipsToBounds = true
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = radius
    }
}

extension UIViewController {
    
    // Show Alert Controller
    func ShowAlert(title: String, text: String) {
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
