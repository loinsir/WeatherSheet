//
//  WeatherSheetApp.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct WeatherSheetApp: App {
    static let store: StoreOf<WeatherSheetReducer> = Store(initialState: WeatherSheetReducer.State(), reducer: { WeatherSheetReducer() })
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: WeatherSheetApp.store)
        }
    }
}
