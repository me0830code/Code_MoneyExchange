//
//  MainViewModel.swift
//  MoneyExchange
//
//  Created by Chien on 2021/1/4.
//  Copyright © 2021 Chien. All rights reserved.
//

import Foundation

enum RequestError: Error {
    
    // Error of Reqeust
    case URLFail(thisURLStr: String)
    case RequestFail
    case DataIsNil
    case DecodeFail
}

class MainViewModel {
    
    // Add USD first because all exchange rates are based on USD
    private var countryList: [String] = ["USD"]
    private var exchangeRateDict: [String: Double] = ["USD": 1]
    
    func fetchExchangeRateAPI(completion: @escaping (_ countryList: [String], _ exchangeRateDict: [String: Double], _ error: RequestError?) -> Void) {

        /*
         {
            "USDUAH": {
                        "Exrate": 24.75109,
                        "UTC": "2019-10-19 09:00:00"
                      },
                .
                .
                .
            "USDAWG": {
                        "Exrate": 1.8,
                        "UTC": "2019-10-19 09:00:00"
                      },
                .
                .
                .
         }
         */
        
        let requestURLStr = "https://tw.rter.info/capi.php"
        
        guard let requestURL = URL(string: requestURLStr) else { completion([], [:], .URLFail(thisURLStr: requestURLStr)) ; return }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in

            guard error == nil else { completion([], [:], .RequestFail) ; return }
            
            guard let thisData = data else { completion([], [:], .DataIsNil) ; return }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: thisData, options: []) as? NSDictionary else {
                completion([], [:], .DecodeFail)
                return
            }
            
            for eachObject in jsonObject.allKeys {
                
                guard let key = eachObject as? String else { return completion([], [:], .DecodeFail) }
                
                // Only focus on USD to others
                if key.contains("USD") {
                    
                    guard let valueDict = jsonObject.value(forKey: key) as? NSDictionary else { return completion([], [:], .DecodeFail) }
                    guard let exchangeRate = valueDict["Exrate"] as? Double else { return completion([], [:], .DecodeFail) }
                    
                    let filterArray = key.components(separatedBy: "USD")
                    let thisCountryName = filterArray[1]
                    
                    if thisCountryName.count > 0 {
                        self.countryList.append(thisCountryName)
                        self.exchangeRateDict[thisCountryName] = exchangeRate
                    }
                }
            }
            
            self.countryList.sort()
            completion(self.countryList, self.exchangeRateDict, nil)
        }.resume()
    }
}
