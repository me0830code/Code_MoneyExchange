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
    
    private var countryList: [String] = []
    private var exchangeRateDict: [String: Double] = [:]
    
    private let countryPickerView: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUpComponents()
        
        ExchangeRateManager().fetchExchangeRateAPI { (countryList, exchangeRateDict) in
            self.countryList = countryList
            self.exchangeRateDict = exchangeRateDict
            
            DispatchQueue.main.async {
                self.countryPickerView.reloadAllComponents()
            }
        }
    }
    
    private func SetUpComponents() {
        
        // Add Gesture To Close Editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.CloseEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // ToolBar Fot fromCountryTF & toCountryTF
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.CloseEditing))
        toolBar.setItems([doneBtn], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // Text Field's Setting
        fromCountryTF.delegate = self
        fromCountryTF.inputView = countryPickerView
        fromCountryTF.inputAccessoryView = toolBar
        
        fromCountryTF.layer.borderColor = UIColor.clear.cgColor
        fromCountryTF.layer.borderWidth = 5
        fromCountryTF.layer.cornerRadius = 5
        fromCountryTF.clipsToBounds = true
        
        toCountryTF.delegate = self
        toCountryTF.inputView = countryPickerView
        toCountryTF.inputAccessoryView = toolBar
        
        toCountryTF.layer.borderColor = UIColor.clear.cgColor
        toCountryTF.layer.borderWidth = 5
        toCountryTF.layer.cornerRadius = 5
        toCountryTF.clipsToBounds = true
        
        amountTF.delegate = self
        amountTF.keyboardType = .decimalPad
        amountTF.clearButtonMode = .whileEditing
        
        amountTF.layer.borderColor = UIColor.clear.cgColor
        amountTF.layer.borderWidth = 5
        amountTF.layer.cornerRadius = 5
        amountTF.clipsToBounds = true
        
        // Button Setting
        goExchangeBtn.addTarget(self, action: #selector(GoExchange), for: .touchUpInside)
        goExchangeBtn.layer.cornerRadius = 10
        goExchangeBtn.clipsToBounds = true
        
        swapCountryBtn.addTarget(self, action: #selector(SwapCountry), for: .touchUpInside)
        
        // PickerView's Setting
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
    }

    @objc private func GoExchange() {
        
        // Close Editing and Init Result & ExchangeRate
        self.CloseEditing()
        self.resultLabel.text = "0"
        self.exchangeRateLabel.text = "0"
        
        if CheckInputIsLegal() {
            
            guard let amountStr = amountTF.text else { return }
            guard let amountValue = Double(amountStr) else { return }
            
            guard let fromCountryStr = fromCountryTF.text else { return }
            guard let fromCountryRateValue = self.exchangeRateDict[fromCountryStr] else { return }
            
            guard let toCountryStr = toCountryTF.text else { return }
            guard let toCountryRateValue = self.exchangeRateDict[toCountryStr] else { return }
            
            let fromCountry_to_usd: Double = 1 / fromCountryRateValue
            let usd_to_toCountry: Double = toCountryRateValue
            let exchangeRateValue: Double = fromCountry_to_usd * usd_to_toCountry
            
            let resultValue:  Double = amountValue * exchangeRateValue
            
            self.resultLabel.text = "\(resultValue)"
            self.exchangeRateLabel.text = "\(exchangeRateValue)"
        } else {
            
            self.ShowAlert(title: "Oops", text: "There is something wrong :(\nPlease check input data again !")
        }
    }

    private func CheckInputIsLegal() -> Bool {
        
        guard let amountStr = amountTF.text else { return false }
        guard let fromCountryStr = fromCountryTF.text else { return false }
        guard let toCountryStr = toCountryTF.text else { return false }
        
        // Rec Color To Fail Input Data
        amountTF.layer.borderColor = Double(amountStr) == nil ? UIColor.red.cgColor : UIColor.clear.cgColor
        fromCountryTF.layer.borderColor = fromCountryStr.count == 0 ? UIColor.red.cgColor : UIColor.clear.cgColor
        toCountryTF.layer.borderColor = toCountryStr.count == 0 ? UIColor.red.cgColor : UIColor.clear.cgColor
        
        if Double(amountStr) == nil || fromCountryStr.count == 0 || toCountryStr.count == 0 {
            return false
        }
        
        return true
    }
    
    @objc private func SwapCountry() {
        let tempCountryName = fromCountryTF.text
        fromCountryTF.text = toCountryTF.text
        toCountryTF.text = tempCountryName
    }
    
    @objc private func CloseEditing() {
        fromCountryTF.resignFirstResponder()
        toCountryTF.resignFirstResponder()
        amountTF.resignFirstResponder()
    }
}

extension MoneyExchangeVC: UITextFieldDelegate {
    
    // Only Amount TextField Can Handle Text
    // fromCountryTF & toCountryTF -> Text Only from PickerView
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        switch textField {
            case amountTF : return true
            default : return false
        }
    }

    // Only Amount TextField Can Handle Text
    // fromCountryTF & toCountryTF -> Text Only from PickerView
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
            case amountTF : return true
            default : return false
        }
    }
}

extension MoneyExchangeVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
    }
    
    func  pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if fromCountryTF.isEditing {
            fromCountryTF.text = countryList[row]
        } else if self.toCountryTF.isEditing {
            toCountryTF.text = countryList[row]
        }
    }
}

