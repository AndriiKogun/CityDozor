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
    
    private let baseUrl = "https://city.dozor.tech/data"
    
    func getRoutes(completion: @escaping ([Route]?) -> ()) {
        let headers: HTTPHeaders = ["Cookie" : "gts.web.uuid=A8E60A40-25A6-4F6E-A0AA-A17CBDE8EE8C; gts.web.city=khmelnyckyi"]
        let parameters = ["t" : 1]
        Alamofire.request(baseUrl, method: .get, parameters: parameters, headers: headers).responseJSON(completionHandler: { (response) in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let data = response.data, let model = try? JSONDecoder().decode(ResponseRoutes.self, from: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        completion(model.data)
                    }
                }
            })
//        debugPrint(request)
    }
    
    func getTransport(routeId: Double, completion: @escaping ([Transport]?) -> ()) {
        let headers: HTTPHeaders = ["Cookie" : "gts.web.uuid=A8E60A40-25A6-4F6E-A0AA-A17CBDE8EE8C; gts.web.city=khmelnyckyi"]
        let parameters = ["t" : 2,
                          "p" : routeId]
        Alamofire.request(baseUrl, method: .get, parameters: parameters, headers: headers).responseJSON(completionHandler: { (response) in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let data = response.data, let model = try? JSONDecoder().decode(ResponseRouteTransport.self, from: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        completion(model.data.first?.transport)
                    }
                }
            })
//        debugPrint(request)
    }

}

struct ResponseRouteTransport: Decodable {
    let data: [RouteTransport]
}

struct RouteTransport: Decodable {
    var id: Double
    var transport: [Transport]
    
    enum CodingKeys : String, CodingKey {
        case id = "rId"
        case transport = "dvs"
    }
}

struct Transport: Decodable {
    var id: Double
    var coordinates: Coordinates
    var speed: Double
    var azi: Double
    var plateNumber: String
    var dis: Bool
    var rad: Bool
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case coordinates = "loc"
        case speed = "spd"
        case azi = "azi"
        case plateNumber = "gNb"
        case dis = "dis"
        case rad = "rad"
    }
}


struct ResponseRoutes: Decodable {
    var data: [Route]
}

class Route: Decodable {
    var id: Double
    var number: String
    var name: [String]
    var type: String
    var stops: [BusStop]
    var routeCoordinates: [RouteCoordinates]
    
    var transport = [Transport]()
    var color = Appearance.RouteColor.red
    var isSelected = false
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case number = "sNm"
        case name = "nm"
        case type = "inf"
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




