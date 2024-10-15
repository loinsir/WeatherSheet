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
    var oneCall: @Sendable (OneCallRequestModel) async throws(AFError) -> WeatherData
}

extension WeatherService: DependencyKey {
    static let liveValue: WeatherService = .init(
        oneCall: { requestModel async throws(AFError) -> WeatherData in
            let api_host = "https://api.openweathermap.org/data/3.0/onecall"
            
            guard let url = URL(string: api_host) else {
                throw AFError.invalidURL(url: api_host)
            }
            
            let response = AF.request(url, method: .get, parameters: requestModel, encoder: .urlEncodedForm)
                .serializingDecodable(WeatherData.self)
            
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
