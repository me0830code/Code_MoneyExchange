//
//  MainViewController.swift
//  MoneyExchange
//
//  Created by Chien on 2021/1/4.
//  Copyright © 2021 Chien. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var fromCountryTF: UITextField! {
        didSet {
            
            // Setting fromCountryTF
            fromCountryTF.delegate = self
            fromCountryTF.inputView = countryPickerView
            fromCountryTF.inputAccessoryView = toolBar
            fromCountryTF.roundedCorner(by: 5)
        }
    }
    
    @IBOutlet weak var toCountryTF: UITextField! {
        didSet {
            
            // Setting toCountryTF
            toCountryTF.delegate = self
            toCountryTF.inputView = countryPickerView
            toCountryTF.inputAccessoryView = toolBar
            toCountryTF.roundedCorner(by: 5)
        }
    }
    
    @IBOutlet weak var swapCountryBtn: UIButton! {
        didSet {
            
            // Setting swapCountryBtn
            swapCountryBtn.addTarget(self, action: #selector(SwapCountry), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var amountTF: UITextField! {
        didSet {
            
            // Setting amountTF
            amountTF.delegate = self
            amountTF.keyboardType = .decimalPad
            amountTF.clearButtonMode = .whileEditing
            amountTF.roundedCorner(by: 5)
        }
    }
    
    @IBOutlet weak var goExchangeBtn: UIButton! {
        didSet {
            
            // Setting goExchangeBtn
            goExchangeBtn.addTarget(self, action: #selector(GoExchange), for: .touchUpInside)
            goExchangeBtn.roundedCorner(by: 5)
        }
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    
    private let mainViewModel = MainViewModel()

    private let countryPickerView: UIPickerView = UIPickerView()
    
    private var countryList: [String] = []
    
    private var exchangeRateDict: [String: Double] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUpComponents()
        
        mainViewModel.fetchExchangeRateAPI { (countryList, exchangeRateDict, error) in
            
            self.countryList = countryList
            self.exchangeRateDict = exchangeRateDict
            
            DispatchQueue.main.async { self.countryPickerView.reloadAllComponents() }
        }
    }
    
    private let toolBar: UIToolbar = {
    
        // ToolBar Fot fromCountryTF & toCountryTF
        let thisToolBar = UIToolbar()
        thisToolBar.barStyle = .default
        thisToolBar.sizeToFit()

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CloseEditing))

        thisToolBar.setItems([cancelButton], animated: false)
        thisToolBar.isUserInteractionEnabled = true
        
        return thisToolBar
    }()
    
    private func SetUpComponents() {
        
        // Add Gesture To Close Editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.CloseEditing))
        self.view.addGestureRecognizer(tapGesture)
        
        // PickerView's Setting
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
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
            
            self.resultLabel.text = "\(resultValue.roundToPlaces(toDigit: 5))"
            self.exchangeRateLabel.text = "\(exchangeRateValue.roundToPlaces(toDigit: 5))"
        } else {
            
            self.ShowAlert(title: "Oops", text: "There is something wrong :(\nPlease check input data again !")
        }
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

extension MainViewController: UITextFieldDelegate {
    
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

extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        
        if fromCountryTF.isEditing { fromCountryTF.text = countryList[row] ; fromCountryTF.resignFirstResponder() }
        else if self.toCountryTF.isEditing { toCountryTF.text = countryList[row] ; toCountryTF.resignFirstResponder() }
    }
}
