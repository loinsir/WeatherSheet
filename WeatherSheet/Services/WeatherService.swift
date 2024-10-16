//
//  WeatherService.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/15/24.
//

import Alamofire
import Dependencies
import Foundation

struct WeatherService {
    static let API_HOST: String = "https://api.openweathermap.org/data/3.0/onecall"
    
    var oneCall: @Sendable (OneCallRequestModel) async throws(AFError) -> WeatherData
    var daily: @Sendable (DailyWeatherRequestModel) async throws(AFError) -> DailyForecastData
}

extension WeatherService: DependencyKey {
    static let liveValue: WeatherService = .init(
        oneCall: { requestModel async throws(AFError) -> WeatherData in
            guard let url = URL(string: API_HOST) else {
                throw AFError.invalidURL(url: API_HOST)
            }
            
            let response = AF.request(url, parameters: requestModel, encoder: .urlEncodedForm)
                .serializingDecodable(WeatherData.self)
            
            switch await response.result {
            case .success(let data): return data
            case .failure(let error): throw error
            }
        },
        daily: { requestModel async throws(AFError) -> DailyForecastData in
            guard let url = URL(string: API_HOST + "/day_summary") else { throw .invalidURL(url: API_HOST + "/day_summary")
            }
            
            let response = AF.request(url, parameters: requestModel, encoder: .urlEncodedForm)
                .serializingDecodable(DailyForecastData.self)
            
            switch await response.result {
            case .success(let data): return data
            case .failure(let error): throw error
            }
        }
    )
}

extension DependencyValues {
    var weatherService: WeatherService {
        get { self[WeatherService.self] }
        set { self[WeatherService.self] = newValue }
    }
}
