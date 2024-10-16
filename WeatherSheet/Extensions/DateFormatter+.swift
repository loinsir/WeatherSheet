//
//  DateFormatter+.swift
//  WeatherSheet
//
//  Created by 김인환 on 10/19/24.
//

import Foundation

extension DateFormatter {
    static let yyyyMMddDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
