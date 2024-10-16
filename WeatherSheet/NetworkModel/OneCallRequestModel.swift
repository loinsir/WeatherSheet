//
//  OneCallRequestModel.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/15/24.
//

import Foundation

struct OneCallRequestModel: Encodable {
    let lat: Double
    let lon: Double
    let appid: String
    let units: Unit
    let exclude: [Exclude]
    
    enum Unit: String, Encodable {
        case metric, imperial, standard
        
        enum CodingKeys: String, CodingKey {
            case value = "units"
        }
    }
    
    enum Exclude: String, Encodable {
        case minutely, hourly, daily, alerts
        
        enum CodingKeys: String, CodingKey {
            case value = "exclude"
        }
    }
}
