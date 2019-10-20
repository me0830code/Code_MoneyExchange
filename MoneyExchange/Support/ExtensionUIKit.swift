//
//  ExtensionUIKit.swift
//  MoneyExchange
//
//  Created by Chien on 2019/10/20.
//  Copyright © 2019 Chien. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Show Alert Controller
    func ShowAlert(title: String, text: String) {
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
