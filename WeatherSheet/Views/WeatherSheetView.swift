//
//  WeatherSheetView.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import SwiftUI

struct WeatherSheetView: View {
    let store: StoreOf<WeatherSheetReducer>
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "cloud.sun")
                Text("기상 상태")
                    .font(.title2)
                    .bold()
            }
            .padding(.bottom, 10)
            HStack {
                Spacer(minLength: 0)
                ForEach(store.dates, id: \.self) { date in
                    Button {
                        store.send(.onTapDate(date))
                    } label: {
                        VStack {
                            Text("\(Calendar.current.veryShortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1])")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .padding(.bottom, 5)
                            if let day = Calendar.current.dateComponents([.day], from: date).day {
                                Text("\(day)")
                                    .font(.title2)
                                    .foregroundStyle(date == store.selectedDate ? Color.white : Color.black)
                                    .frame(width: 40, height: 40)
                                    .background(date == store.selectedDate ? Color.primary : Color.clear)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            if let selectedDate = store.selectedDate {
                Text(selectedDate, style: .date)
            } else {
                Spacer()
                    .frame(height: 30)
            }
            
            
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    WeatherSheetView(store: Store(initialState: WeatherSheetReducer.State(), reducer: { WeatherSheetReducer() }))
        .environment(\.locale, Locale(identifier: "ko_KR"))
}
