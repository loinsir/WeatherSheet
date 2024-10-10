//
//  ContentView.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    let store: StoreOf<WeatherSheetReducer>
    
    var body: some View {
        WeatherSheetView(store: store)
    }
}

#Preview {
    ContentView(store: Store(
        initialState: WeatherSheetReducer.State(),
        reducer:  { WeatherSheetReducer() }
    ))
}
