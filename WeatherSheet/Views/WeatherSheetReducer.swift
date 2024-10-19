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
    
    private let yyyyMMddDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @ObservableState
    struct State {
        var dates: [Date] = []
        var selectedDate: Date?
        var currentWeatherData: HourlyWeatherData?
        var hourlyWeatherData: [HourlyWeatherData]?
        var dailyWeatherData: [DailyWeatherData]?
        
        var selectedDateWeatherData: DailyForecastData?
        
        var isSelectedDateToday: Bool {
            let currentDate = Date()
            guard let selectedDate else { return false }
            
            let selectedDateString = DateFormatter.yyyyMMddDateFormatter.string(from: selectedDate)
            let currentDateString = DateFormatter.yyyyMMddDateFormatter.string(from: currentDate)
            
            return selectedDateString == currentDateString
        }
        
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
        
        case setSelectedDateWeatherData(DailyForecastData)
    }
    
    @Dependency(\.weatherService) private var weatherService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let requestModel = OneCallRequestModel(lat: SEOUL_LATITUDE, lon: SEOUL_LONGITUDE, appid: Constants.API_KEY, units: .metric, exclude: [.minutely])
                    let weatherData = try await weatherService.oneCall(requestModel)
                    
                    return await send(.setWeatherData(weatherData))
                }

            case .onTapDate(let date):
                state.selectedDate = date
                
                return .run { [selectedDate = state.selectedDate] send in
                    guard let selectedDate else { return }
                    let dateString = DateFormatter.yyyyMMddDateFormatter.string(from: selectedDate)
                    let requestModel = DailyWeatherRequestModel(lat: SEOUL_LATITUDE, lon: SEOUL_LONGITUDE, date: dateString, appid: Constants.API_KEY, units: .metric)
                    let response = try await weatherService.daily(requestModel)

                    return await send(.setSelectedDateWeatherData(response))
                }
                
            case .setWeatherData(let weatherData):
                state.currentWeatherData = weatherData.current
                state.hourlyWeatherData = weatherData.hourly
                state.dailyWeatherData = weatherData.daily
                state.dates = weatherData.daily.compactMap({ data in
                    Date(timeIntervalSince1970: TimeInterval(data.dt))
                })
                
            case .setSelectedDateWeatherData(let dailyWeatherData):
                state.selectedDateWeatherData = dailyWeatherData
            }
            
            return .none
        }
    }
}
