//
//  DailyWeatherRequestModel.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/17/24.
//

import Foundation

struct DailyWeatherRequestModel: Encodable {
    let lat: Double
    let lon: Double
    let date: String
    let appid: String
}
