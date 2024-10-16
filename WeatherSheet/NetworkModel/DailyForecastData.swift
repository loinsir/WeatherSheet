//
//  DailyForecastData.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/17/24.
//

import Foundation

struct DailyForecastData: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String
    let date: String
    let units: String
    let cloudCover: CloudCover
    let humidity: Humidity
    let preciptation: Preciptation
    let temperature: Temperature
    let pressure: Pressure
    let wind: Wind
}

struct CloudCover: Decodable {
    let afternoon: Double
}

struct Humidity: Decodable {
    let afternoon: Double
}

struct Preciptation: Decodable {
    let total: Double
}

struct Temperature: Decodable {
    let min: Double
    let max: Double
    let afternoon: Double
    let night: Double
    let evening: Double
    let morning: Double
}

struct Pressure: Decodable {
    let afternoon: Double
}

struct Wind: Decodable {
    let max: MaxWind
}

struct MaxWind: Decodable {
    let speed: Double
    let direction: Double
}
