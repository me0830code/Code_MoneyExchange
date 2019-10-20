//
//  ExchangeRateManager.swift
//  MoneyExchange
//
//  Created by Chien on 2019/10/20.
//  Copyright © 2019 Chien. All rights reserved.
//

import Foundation

enum ErrorType: Error {
    case FailURL
    case FailJsonDecode
}

class ExchangeRateManager {
    
    // Add USD first because all exchange rates are based on USD
    private var countryList: [String] = ["USD"]
    private var exchangeRateDict: [String: Double] = ["USD": 1]
    
    func fetchExchangeRateAPI(completion: @escaping (_ countryList: [String], _ exchangeRateDict: [String: Double]) -> Void) {
        
//         {
//            "USDUAH": {
//                        "Exrate": 24.75109,
//                        "UTC": "2019-10-19 09:00:00"
//                       },
//                .
//                .
//                .
//
//            "USDAWG": {
//                        "Exrate": 1.8,
//                        "UTC": "2019-10-19 09:00:00"
//                       }
//         }
        
        guard let requestURL = URL(string: "https://tw.rter.info/capi.php") else {
            
            // Fail to request URL
            return completion([], [:])
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in

            if let data = data {
                
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    
                    // Fail to decode jsonObject
                    return completion([], [:])
                }
                
                for eachObject in jsonObject.allKeys {
                    
                    guard let key = eachObject as? String else { return completion([], [:]) }
                    
                    // Only focus on USD to others
                    if key.contains("USD") {
                        
                        guard let valueDict = jsonObject.value(forKey: key) as? NSDictionary else { return completion([], [:]) }
                        guard let exchangeRate = valueDict["Exrate"] as? Double else { return completion([], [:]) }
                        
                        let filterArray = key.components(separatedBy: "USD")
                        let thisCountryName = filterArray[1]
                        
                        if thisCountryName.count > 0 {
                            self.countryList.append(thisCountryName)
                            self.exchangeRateDict[thisCountryName] = exchangeRate
                        }
                    }
                }
                
                self.countryList.sort()
                completion(self.countryList, self.exchangeRateDict)
            } else {

                completion([], [:])
            }
        }.resume()
    }
}
