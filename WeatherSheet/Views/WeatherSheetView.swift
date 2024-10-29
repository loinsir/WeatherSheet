//
//  WeatherSheetView.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/10/24.
//

import ComposableArchitecture
import Charts
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                        .frame(width: 15)
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
                        Spacer()
                            .frame(width: 15)
                    }
                }
            }
            if let selectedDate = store.selectedDate {
                Text(selectedDate, style: .date)
            } else {
                Spacer()
                    .frame(height: 30)
            }
            Divider()
            
            Group {
                VStack {
                    if let selectedWeatherData = store.selectedDateWeatherData,
                       let currentWeatherData = store.currentWeatherData {
                        HStack {
                            if store.isSelectedDateToday {
                                Text("\(Int(currentWeatherData.temp))°")
                                    .font(.title)
                                    .foregroundStyle(Color.black)
                            } else {
                                Text("\(Int(selectedWeatherData.temperature.max))°")
                                    .font(.title)
                                    .foregroundStyle(Color.black)
                                Text("\(Int(selectedWeatherData.temperature.min))°")
                                    .font(.title)
                                    .foregroundStyle(Color.gray)
                            }
                            Spacer()
                        }
                        HStack {
                            Text(store.isSelectedDateToday ? "최고:\(Int(selectedWeatherData.temperature.max))° 최저: \(Int(selectedWeatherData.temperature.min))°" : "섭씨(°C)")
                                .foregroundStyle(Color.gray)
                            Spacer()
                        }
                    }
                    if let selectedDateHourlyData = store.selectedDateHourlyWeatherData {
                        Chart(selectedDateHourlyData, id: \.dateTime) { data in
                            let time = Date(timeIntervalSince1970: TimeInterval(data.dateTime))
                            AreaMark(
                                x: .value("Hour", time),
                                y: .value("Temp", data.temp)
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        VStack {
                                            Text(date, format: .dateTime.hour())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Divider()
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("강수 확률")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    Text("강수 확률: \(Int((store.selectedDateWeatherData?.precipitation?.total ?? 0) * 100))%")
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let store = Store(
        initialState: WeatherSheetReducer.State(),
        reducer: { WeatherSheetReducer() },
        withDependencies: { dependencyValues in
            dependencyValues.locationService = .previewValue
        }
    )
    
    WeatherSheetView(store: store)
        .environment(\.locale, Locale(identifier: "ko_KR"))
}
