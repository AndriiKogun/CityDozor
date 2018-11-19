//
//  Manager.swift
//  CityDozor
//
//  Created by A K on 11/18/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Manager {
    
    static let shared = Manager()
    
    let url = "https://city.dozor.tech/data"
    let headers: HTTPHeaders = ["Cookie" : "gts.web.uuid=A8E60A40-25A6-4F6E-A0AA-A17CBDE8EE8C; gts.web.city=khmelnyckyi"]

    //let headers: HTTPHeaders = [
    //    "Accept" : "application/json",
    //    "Accept-Encoding" : "gzip, deflate, br",
    //    "Accept-Language" : "en-US,en;q=0.9,ru;q=0.8,pl;q=0.7,uk;q=0.6",
    //    "Connection" : "keep-alive",
    //    "Cookie" : "gts.web.uuid=A8E60A40-25A6-4F6E-A0AA-A17CBDE8EE8C; gts.web.city=khmelnyckyi",
    //    "Host" : "city.dozor.tech",
    //    "Referer" : "https://city.dozor.tech/ua/khmelnyckyi/city"
    //]
    
    func loadMainRequest(with completion: @escaping ([MainRequestModel]) -> ()) {
        //https://city.dozor.tech/data?t=1
        let parameters = ["t" : "1"]
        
        let request = Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { (response) in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        print("Error: \(String(describing: response.result.error))")
                        return
                }
                
                var dataSource = [MainRequestModel]()
                
                let array = JSON(value)["data"].array
                array?.forEach({ (json) in
                    var names = [String]()
                    json["zns"].array?.forEach({ (stop) in
                        guard let stopName = stop["nm"].array?.first?.stringValue else { return }
                        names.append(stopName)
                    })
                    
                    let model = MainRequestModel(itemId: json["id"].intValue,
                                                 itemName: json["sNm"].stringValue,
                                                 stops: names)
                    dataSource.append(model)
                })
                
                completion(dataSource)
            })
        
        debugPrint(request)
    }
        
    func loadMarshrutka() {
        //https://city.dozor.tech/data?t=2&p=1501
        
        let parameters = ["t" : "2",
                          "p" : "1501"]
        
        let request = Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { (response) in
                guard response.result.isSuccess,
                    let value = response.result.value else {
                        print("Error: \(String(describing: response.result.error))")
                        return
                }
            })
        
        debugPrint(request)
    }
}
