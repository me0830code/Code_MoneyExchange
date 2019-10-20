//
//  MoneyExchangeVC.swift
//  MoneyExchange
//
//  Created by Chien on 2019/10/20.
//  Copyright © 2019 Chien. All rights reserved.
//

import UIKit


class MoneyExchangeVC: UIViewController {
    
    
    @IBOutlet weak var fromCountryTF: UITextField!
    @IBOutlet weak var toCountryTF: UITextField!
    @IBOutlet weak var swapCountryBtn: UIButton!
    
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var goExchangeBtn: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUpComponents()
    }
    
    private func SetUpComponents() {
    
    }
    
    
    
}
