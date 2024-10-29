//
//  WeatherSheetReducer.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import MapKit
import SwiftUI

@Reducer
struct WeatherSheetReducer {
    @ObservableState
    struct State {
        var currentLocation: CLLocationCoordinate2D?
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
        
        var selectedDateHourlyWeatherData: [HourlyWeatherData]? {
            guard let selectedDate, let hourlyWeatherData else { return nil }
            
            let data = hourlyWeatherData.sorted(by: { $0.dateTime < $1.dateTime }).filter({ data in
                let dateString = DateFormatter.yyyyMMddDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.dateTime)))
                let selectedDateString = DateFormatter.yyyyMMddDateFormatter.string(from: selectedDate)
                return dateString == selectedDateString
            }).filter({ data in
                let hour = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(data.dateTime)))
                return hour.isMultiple(of: 2)
            })
            
            return data
        }
        
        enum DayOrNight {
            case day
            case night
        }
    }
    
    enum Action {
        case onAppear
        case onTapDate(Date)
        
        case setLocation(CLLocationCoordinate2D)
        case setWeatherData(WeatherData)
        
        case setSelectedDateWeatherData(DailyForecastData)
    }
    
    @Dependency(\.weatherService) private var weatherService
    @Dependency(\.locationService) private var locationService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    guard let currentLocation = try await locationService.currentLocation() else { return }
                    
                    let requestModel = OneCallRequestModel(
                        lat: currentLocation.coordinate.latitude,
                        lon: currentLocation.coordinate.longitude,
                        appid: Constants.API_KEY,
                        units: .metric,
                        exclude: [.minutely]
                    )
                    let weatherData = try await weatherService.oneCall(requestModel)
                    
                    await send(.setLocation(currentLocation.coordinate))
                    return await send(.setWeatherData(weatherData))
                }

            case .onTapDate(let date):
                state.selectedDate = date

                return .run { [copyState = state] send in
                    guard let selectedDate = copyState.selectedDate,
                          let currentLocation = copyState.currentLocation else { return }

                    let dateString = DateFormatter.yyyyMMddDateFormatter.string(from: selectedDate)
                    let requestModel = DailyWeatherRequestModel(
                        lat: currentLocation.latitude,
                        lon: currentLocation.longitude,
                        date: dateString,
                        appid: Constants.API_KEY,
                        units: .metric
                    )
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
                
            case .setLocation(let coordinateData):
                state.currentLocation = coordinateData
                
            case .setSelectedDateWeatherData(let dailyWeatherData):
                state.selectedDateWeatherData = dailyWeatherData
            }
            
            return .none
        }
    }
}
