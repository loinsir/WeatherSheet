//
//  WeatherSheetReducer.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct WeatherSheetReducer {
    @ObservableState
    struct State {
        var dates: [Date] = []
        var selectedDate: Date?
    }
    
    enum Action {
        case onAppear
        case onTapDate(Date)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dates = [-3, -2, -1, 0, 1, 2, 3]
                    .compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: Date()) })

            case .onTapDate(let date):
                state.selectedDate = state.dates.first(where: { $0 == date })
            }
            
            return .none
        }
    }
}
