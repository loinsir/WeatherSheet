//
//  WeatherSheetReducer.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import MapKit
import Foundation

@Reducer
struct WeatherSheetReducer {
    private let SEOUL_LATITUDE: Double = 37.5667
    private let SEOUL_LONGITUDE: Double = 126.978
    
    @ObservableState
    struct State {
        var dates: [Date] = []
        var selectedDate: Date?
        var currentWeatherData: HourlyWeatherData?
        var hourlyWeatherData: [HourlyWeatherData]?
        var dailyWeatherData: [DailyWeatherData]?
        
        var currentDayOrNight: DayOrNight? {
            let currentTime = Date()
            guard let currentDaySunrise = currentWeatherData?.sunrise,
                  let currentDaySunset = currentWeatherData?.sunset
            else { return nil }
            
            let currentDateSunrise = Date(timeIntervalSince1970: TimeInterval(currentDaySunrise))
            let currentDateSunset = Date(timeIntervalSince1970: TimeInterval(currentDaySunset))
            
            return currentDateSunrise...currentDateSunset ~= currentTime ? .day : .night
        }
        
        enum DayOrNight {
            case day
            case night
        }
    }
    
    enum Action {
        case onAppear
        case onTapDate(Date)
        case setWeatherData(WeatherData)
    }
    
    @Dependency(\.weatherService) private var weatherService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dates = [-3, -2, -1, 0, 1, 2, 3]
                    .compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: Date()) })
                return .run { send in
                    let responseModel = OneCallRequestModel(lat: SEOUL_LATITUDE, lon: SEOUL_LONGITUDE, appid: Constants.API_KEY, units: .metric, exclude: [.minutely])
                    let weatherData = try await weatherService.oneCall(responseModel)
                    
                    return await send(.setWeatherData(weatherData))
                }

            case .onTapDate(let date):
                state.selectedDate = state.dates.first(where: { $0 == date })
                
            case .setWeatherData(let weatherData):
                state.currentWeatherData = weatherData.current
                state.hourlyWeatherData = weatherData.hourly
                state.dailyWeatherData = weatherData.daily
            }
            
            return .none
        }
    }
}
