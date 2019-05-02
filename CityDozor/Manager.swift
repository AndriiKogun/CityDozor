//
//  Manager.swift
//  CityDozor
//
//  Created by A K on 11/18/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit
import Alamofire

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
    
    func loadMainRequest(with completion: @escaping ([BusModel]) -> ()) {
        //https://city.dozor.tech/data?t=1
        let parameters = ["t" : "1"]
        
        let request = Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { (response) in
                
                guard let data = response.data, let model = try? JSONDecoder().decode(MainData.self, from: data) else {
                    return
                }
                completion(model.data)
            })
        
        debugPrint(request)
    }
}

struct MainData: Decodable {
    var data: [BusModel]
}

struct BusModel: Decodable {
    var id: Double
    var number: String
    var name: [String]
    var stops: [BusStop]
    var routeCoordinates: [RouteCoordinates]
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case number = "sNm"
        case name = "nm"
        case stops = "zns"
        case routeCoordinates = "lns"
    }
}

struct RouteCoordinates: Decodable {
    var coordinatesSection: [Coordinates]
    
    enum CodingKeys : String, CodingKey {
        case coordinatesSection = "pts"
    }
}

struct BusStop: Decodable {
    var id: Double
    var name: [String]
    var sourceCoordinates: Coordinates
    var destinationCoordinates: Coordinates

    enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "nm"
        case sourceCoordinates = "ctr"
        case destinationCoordinates = "pt"
    }
}

struct Coordinates: Decodable {
    var latitude: Double
    var longitude: Double
    
    enum CodingKeys : String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}


